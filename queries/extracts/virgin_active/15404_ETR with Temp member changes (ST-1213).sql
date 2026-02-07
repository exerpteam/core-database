SELECT
    i3.CENTER_NAME AS CLUB_NAME,
    i3.PID AS PERSON_ID,
    i3.AGE ,
    i3.FIRSTNAME ,
    i3.LASTNAME ,
    i3.SUBSCRIPTION AS SUBSCRIPTION_ID,
    i3.SUBSCRIPTION_TYPE ,
    i3.PRODUCT_GROUP ,
    i3.SUBSCRIPTION_BINDING_DATE ,
    i3.TERMINATION_TYPE AS TERMINATION_CATEGORY,
    i3.REASON_FOR_LEAVING ,
    i3.SUBSCRIPTION_END_DATE ,
    i3.DEBT_CASE_AMOUNT ,
    i3.DDI_STOPPED AS DDI_STOP_DATE,
    i3.COMING_OUT_OF_FREEZE ,
    i3.ENTERING_FREEZE AS GOING_ON_TO_FREEZE,
    i3.COMING_OFF_FREEZE_START AS FREEZE_START_DATE,
    i3.COMING_OFF_FREEZE_END AS FREEZE_END_DATE,
    CASH_TO_INCLUDE
FROM
    (
        SELECT
            c.SHORTNAME CENTER_NAME,
            p.CENTER || 'p' || p.ID PID,
            floor(months_between(TRUNC(SYSDATE),p.BIRTHDATE)/12) AGE,
            p.FIRSTNAME FIRSTNAME,
            p.LASTNAME LASTNAME,
            s.CENTER || 'ss' || s.ID SUBSCRIPTION,
            prod.NAME SUBSCRIPTION_TYPE,
            pg.NAME PRODUCT_GROUP,
            DECODE(i2.CASH_TO_INCLUDE,1,'Subscription Ended/','') || DECODE(i2.ENDING_SUB,1,'Subscription Ended/','')
            || DECODE(i2.NEW_DEBT_CASE,1,'Debt Case/','') || DECODE(i2.ENTERING_FREEZE,1,'Freeze/','') || DECODE
            (i2.NEW_AGREEMENT_CASE,1,'DDI Case/','') TERMINATION_TYPE,
            MAX(
                CASE
                    WHEN q.QUESTIONS IS NOT NULL
                    THEN EXTRACTVALUE(xmltype(
                            CASE
                                WHEN LENGTH(q.QUESTIONS) < 2001
                                THEN UTL_I18N.RAW_TO_CHAR(DBMS_LOB.SUBSTR(q.QUESTIONS, 4000,1), 'UTF8')
                                ELSE UTL_I18N.RAW_TO_CHAR(DBMS_LOB.SUBSTR(q.QUESTIONS, 2000,1), 'UTF8') ||
                                    UTL_I18N.RAW_TO_CHAR(DBMS_LOB.SUBSTR(q.QUESTIONS, 2000,2001), 'UTF8')
                            END ), '//question[id/text()='||TO_CHAR(qa.QUESTION_ID)||']/options/option[id/text()='||
                        TO_CHAR(qa.NUMBER_ANSWER)||']/optionText')
                END) AS REASON_FOR_LEAVING,
            i2.ENDING_SUB_END_DATE SUBSCRIPTION_END_DATE,
            i2.DEBT_CASE_AMOUNT DEBT_CASE_AMOUNT,
            i2.NEW_AGREEMENT_CASE_START_DATE DDI_STOPPED,
            i2.COMING_OUT_OF_FREEZE COMING_OUT_OF_FREEZE,
            i2.ENTERING_FREEZE_START_DATE COMING_OFF_FREEZE_START,
            i2.ENTERING_FREEZE_END_DATE COMING_OFF_FREEZE_END,
            ENTERING_FREEZE ENTERING_FREEZE,
            ENTERING_FREEZE_START_DATE ENTERING_FREEZE_START_DATE,
            ENTERING_FREEZE_END_DATE ENTERING_FREEZE_END_DATE,
            s.BINDING_END_DATE SUBSCRIPTION_BINDING_DATE,
            CASH_TO_INCLUDE
        FROM
            (
                /********************* DRAFT 2 PART BEGIN **************************/
                SELECT
                    CASE
                            /* The cash subs that was in WINDOW at cut date and when the report was ran have sub state
                            NONE should be included*/
                        WHEN FUTURE_START_DATE IS NOT NULL
                            AND NOT( ENTERING_FREEZE = 1
                                OR NEW_DEBT_CASE = 1
                                OR NEW_AGREEMENT_CASE = 1 )
                        THEN 0
                        WHEN CASH_TO_INCLUDE = 1
                        THEN 1
                            /* All cash subs that has not been covered by above and where we don't hve a a freeze, debt
                            , or agreement case should not be in the report */
                        WHEN (LIVE_CLOSING = 1
                                OR COMING_OUT_OF_FREEZE = 1)
                            AND ( ST_TYPE = 0
                                AND NOT( ENTERING_FREEZE = 1
                                    OR NEW_DEBT_CASE = 1
                                    OR NEW_AGREEMENT_CASE = 1 ) )
                        THEN 0
                        WHEN (LIVE_CLOSING = 1
                                OR COMING_OUT_OF_FREEZE = 1)
                            AND (ENTERING_FREEZE = 1
                                OR ENDING_SUB = 1
                                OR NEW_DEBT_CASE = 1
                                OR NEW_AGREEMENT_CASE = 1 )
                        THEN 1
                        ELSE 0
                    END AS SHOWS_IN_ETR,
                    ST_TYPE,
                    SUB_CENTER,
                    SUB_ID,
                    LIVE_CLOSING,
                    COMING_OUT_OF_FREEZE,
                    COMING_OFF_FREEZE_START,
                    COMING_OFF_FREEZE_END,
                    ENTERING_FREEZE,
                    ENTERING_FREEZE_START_DATE,
                    ENTERING_FREEZE_END_DATE,
                    ENDING_SUB,
                    ENDING_SUB_END_DATE ,
                    ENDING_SUB_SUB_STATE,
                    DEBT_CASE_AMOUNT,
                    NEW_DEBT_CASE,
                    NEW_DEBT_CASE_START_DATE,
                    NEW_AGREEMENT_CASE,
                    NEW_AGREEMENT_CASE_START_DATE,
                    CASH_TO_INCLUDE,
                    FUTURE_START_DATE
                FROM
                    (
                        SELECT
                            
                            CASE
                                WHEN  /* So cash memberships that should be included are ENDED CASH that was in WINDOWS at report end or had a link to product group Temporary Memberships */
                                    ( s.SUB_STATE = 1  AND st.ST_TYPE = 0) and (tpg.ID is not null or i1.WINDOW = 1)
                                THEN 1
                                ELSE 0
                            END AS CASH_TO_INCLUDE,
                            st.ST_TYPE,
                            i1.SUB_CENTER,
                            i1.SUB_ID,
                            i1.LIVE_CLOSING,
                            CASE
                                WHEN sfp.START_DATE IS NOT NULL
                                    AND sfp.END_DATE BETWEEN exerpro.longtodateTZ($$CutDate$$, 'Europe/London') + 1 AND
                                    add_months(exerpro.longtodateTZ($$CutDate$$, 'Europe/London') + 1,1)
                                THEN 1
                                ELSE 0
                            END AS COMING_OUT_OF_FREEZE,
                            sfp.START_DATE COMING_OFF_FREEZE_START,
                            sfp.END_DATE COMING_OFF_FREEZE_END,
                            CASE
                                WHEN sfp2.START_DATE IS NOT NULL
                                    AND (( add_months(exerpro.longtodateTZ($$CutDate$$, 'Europe/London'),1) BETWEEN
                                            sfp2.START_DATE AND sfp2.END_DATE)
                                        AND ( add_months(exerpro.longtodateTZ($$CutDate$$, 'Europe/London') + 1,1)
                                            BETWEEN sfp2.START_DATE AND sfp2.END_DATE))
                                THEN 1
                                ELSE 0
                            END AS ENTERING_FREEZE,
                            sfp2.START_DATE ENTERING_FREEZE_START_DATE,
                            sfp2.END_DATE ENTERING_FREEZE_END_DATE,
                            CASE
                                WHEN s.END_DATE IS NOT NULL
                                    AND s.END_DATE BETWEEN exerpro.longtodateTZ($$CutDate$$, 'Europe/London') + 1 AND
                                    add_months(exerpro.longtodateTZ($$CutDate$$, 'Europe/London') + 1,1)
                                    AND s.SUB_STATE = 1
                                THEN 1
                                ELSE 0
                            END AS ENDING_SUB,
                            s.END_DATE ENDING_SUB_END_DATE,
                            DECODE (s.SUB_STATE, 1,'NONE', 2,'AWAITING_ACTIVATION', 3,'UPGRADED', 4,'DOWNGRADED', 5,
                            'EXTENDED', 6, 'TRANSFERRED',7,'REGRETTED',8,'CANCELLED',9,'BLOCKED','UNKNOWN') AS
                            ENDING_SUB_SUB_STATE,
                            nvl2(debtCase.startdate,1,0) NEW_DEBT_CASE,
                            debtCase.startdate NEW_DEBT_CASE_START_DATE,
                            debtCase.amount DEBT_CASE_AMOUNT,
                            nvl2(agreementCase.startdate,1,0) NEW_AGREEMENT_CASE,
                            agreementCase.startdate NEW_AGREEMENT_CASE_START_DATE,
                            i1.WINDOW,
                            futureSub.START_DATE FUTURE_START_DATE
                        FROM
                            (
                            /********************* START WD1 ***************************/
                            WITH
    params AS
    (
        SELECT
            /*+ materialize */
            longtodateTZ($$CutDate$$, 'Europe/London') cutDateAsDate,
            $$CutDate$$ cutDateAsLong
        FROM
            dual
    )
SELECT DISTINCT
    personid || ', ' || subscriptionId id,
    OWNER_CENTER CENTER,
    personId,
    startdate,
    enddate,
    creation,
    pgName,
    SUM(ACTIVE_CLOSING) ACTIVE_CLOSING,
    SUM(BLOCKED) BLOCKED,
    SUM(FROZEN) FROZEN,
    SUM(MISSING_AGREEMENT) MISSING_DDI,
    SUM(WINDOW) WINDOW,
    SUM(DEFERRED_ONE_MONTH) DEFERRED_ONE_MONTH,
    SUM(DEFERRED_TWO_MONTHS) DEFERRED_TWO_MONTHS,
    SUM(DEFERRED_LATER) DEFERRED_LATER,
    SUM(ACTIVE_CLOSING) + SUM(BLOCKED) + SUM(MISSING_AGREEMENT) + SUM(FROZEN) + SUM(DEFERRED_TWO_MONTHS) + SUM
    (DEFERRED_LATER) + SUM(WINDOW) LIVE_CLOSING,
    SUB_CENTER,
    SUB_ID
FROM
    (
        SELECT
            SU.OWNER_CENTER,
            SU.OWNER_ID,
            SU.OWNER_CENTER || 'p' || SU.OWNER_ID personId,
            SU.CENTER || 'ss' || SU.ID subscriptionId,
            SU.CENTER SUB_CENTER,
            SU.ID SUB_ID,
            PR.name memType,
            PG.NAME pgName,
            TO_CHAR(SU.START_DATE, 'YYYY-MM-DD') STARTDATE,
            TO_CHAR(SU.END_DATE, 'YYYY-MM-DD') ENDDATE,
            TO_CHAR(longtodateTZ(SU.CREATION_TIME, 'Europe/London'), 'YYYY-MM-DD') CREATION,
            TO_CHAR(longtodateTZ(SCL1.ENTRY_START_TIME, 'Europe/London'), 'YYYY-MM-DD HH24:MI') ENTRY_START,
            TO_CHAR(longtodateTZ(SCL1.ENTRY_END_TIME, 'Europe/London'), 'YYYY-MM-DD HH24:MI') ENTRY_END ,
            CASE
                WHEN SCL1.STATEID IN (2,4,8)
                THEN 1
                ELSE 0
            END ACTIVE_CLOSING,
            CASE
                WHEN SCL1.STATEID IN (2,4,8)
                    AND SCL1.SUB_STATE IN (9)
                THEN -1
                ELSE 0
            END BLOCKED,
            CASE
                WHEN SCL1.STATEID IN (4)
                    AND SCL1.SUB_STATE NOT IN (9)
                THEN -1
                ELSE 0
            END FROZEN,
            CASE
                WHEN SCL1.STATEID IN (2,4,8)
                    AND SCL1.STATEID NOT IN (4)
                    AND SCL1.SUB_STATE NOT IN (9)
                    AND ((memberAgreementCase.PERSONCENTER IS NOT NULL
                            AND EXISTS(
                            (
                                SELECT
                                    1,
                                    ar.balance - SUM(NVL(art.AMOUNT,0)) AS BalanceAtCutDate
                                FROM
                                    ACCOUNT_RECEIVABLES ar
                                CROSS JOIN
                                    params
                                LEFT JOIN
                                    AR_TRANS art
                                ON
                                    art.center = ar.center
                                    AND art.id = ar.id
                                    AND art.ENTRY_TIME >= params.CutDateAsLong
                                WHERE
                                    ar.AR_TYPE = 4
                                    AND ar.CUSTOMERCENTER = SU.OWNER_CENTER
                                    AND ar.CUSTOMERID = SU.OWNER_ID
                                GROUP BY
                                    ar.center,
                                    ar.id,
                                    ar.AR_TYPE,
                                    ar.CUSTOMERCENTER,
                                    ar.customerid,
                                    ar.balance
                                HAVING
                                    ar.balance - SUM(NVL(art.AMOUNT,0)) < 0)))
                        OR (opAgreementCase.RELATIVECENTER IS NOT NULL
                            AND EXISTS(
                            (
                                SELECT
                                    1,
                                    ar.balance - SUM(NVL(art.AMOUNT,0)) AS BalanceAtCutDate
                                FROM
                                    ACCOUNT_RECEIVABLES ar
                                CROSS JOIN
                                    params
                                LEFT JOIN
                                    AR_TRANS art
                                ON
                                    art.center = ar.center
                                    AND art.id = ar.id
                                    AND art.ENTRY_TIME >= params.CutDateAsLong
                                WHERE
                                    ar.AR_TYPE = 4
                                    AND ar.CUSTOMERCENTER = opAgreementCase.PAYERCENTER
                                    AND ar.CUSTOMERID = opAgreementCase.PAYERID
                                GROUP BY
                                    ar.center,
                                    ar.id,
                                    ar.AR_TYPE,
                                    ar.CUSTOMERCENTER,
                                    ar.customerid,
                                    ar.balance
                                HAVING
                                    ar.balance - SUM(NVL(art.AMOUNT,0)) < 0))))
                THEN -1
                ELSE 0
            END MISSING_AGREEMENT,
            CASE
                WHEN SCL1.STATEID IN (7)
                    AND SCL1.SUB_STATE NOT IN (5)
                    AND ST.ST_TYPE = 0
                    AND ((ST.PERIODCOUNT = 1
                            AND ST.PERIODUNIT = 3)
                        OR (ST.PERIODCOUNT = 12
                            AND ST.PERIODUNIT = 2)
                        OR (ST.PERIODCOUNT = 6
                            AND ST.PERIODUNIT = 2))
                    AND SCL1.SUB_STATE NOT IN (9)
                    AND memberAgreementCase.PERSONCENTER IS NULL
                    AND opAgreementCase.RELATIVECENTER IS NULL
                THEN 1
                ELSE 0
            END WINDOW,
            CASE
                WHEN SCL1.STATEID IN (8)
                    AND SCL1.SUB_STATE NOT IN (9)
                    AND memberAgreementCase.PERSONCENTER IS NULL
                    AND opAgreementCase.RELATIVECENTER IS NULL
                    AND SU.START_DATE <= add_months(params.CutDateAsDate,1)
                THEN -1
                ELSE 0
            END DEFERRED_ONE_MONTH,
            CASE
                WHEN SCL1.STATEID IN (8)
                    AND SCL1.SUB_STATE NOT IN (9)
                    AND memberAgreementCase.PERSONCENTER IS NULL
                    AND opAgreementCase.RELATIVECENTER IS NULL
                    AND SU.START_DATE > add_months(params.CutDateAsDate,1)
                    AND SU.START_DATE <= add_months(params.CutDateAsDate,2)
                THEN -1
                ELSE 0
            END DEFERRED_TWO_MONTHS,
            CASE
                WHEN SCL1.STATEID IN (8)
                    AND SCL1.SUB_STATE NOT IN (9)
                    AND memberAgreementCase.PERSONCENTER IS NULL
                    AND opAgreementCase.RELATIVECENTER IS NULL
                    AND SU.START_DATE > add_months(params.CutDateAsDate,2)
                THEN -1
                ELSE 0
            END DEFERRED_LATER,
            perCreation.txtvalue "Original joined date",
            oldSystemId.txtvalue "Old System Id"
        FROM
            SUBSCRIPTIONS SU
        CROSS JOIN
            params
        INNER JOIN
            SUBSCRIPTIONTYPES ST
        ON
            (
                SU.SUBSCRIPTIONTYPE_CENTER = ST.CENTER
                AND SU.SUBSCRIPTIONTYPE_ID = ST.ID )
        INNER JOIN
            STATE_CHANGE_LOG SCL1
        ON
            (
                SCL1.CENTER = SU.CENTER
                AND SCL1.ID = SU.ID
                AND SCL1.ENTRY_TYPE = 2
                AND SCL1.STATEID IN (2,
                                     4,7,8)
                AND SCL1.BOOK_START_TIME < params.CutDateAsLong + (1000*60*60*24) + 2000
                AND SCL1.ENTRY_START_TIME < params.CutDateAsLong + (1000*60*60*33) )
            AND (
                SCL1.ENTRY_END_TIME IS NULL
                OR SCL1.ENTRY_END_TIME > params.CutDateAsLong + (1000*60*60*33) )
        INNER JOIN
            PRODUCTS PR
        ON
            (
                ST.CENTER = PR.CENTER
                AND ST.ID = PR.ID )
        LEFT JOIN
            PRODUCT_GROUP pg
        ON
            pg.ID = PR.PRIMARY_PRODUCT_GROUP_ID
            AND pg.NAME LIKE 'Mem Cat%'
        LEFT JOIN
            PERSON_EXT_ATTRS perCreation
        ON
            perCreation.PERSONCENTER = SU.OWNER_CENTER
            AND perCreation.PERSONID = SU.OWNER_ID
            AND perCreation.NAME = 'CREATION_DATE'
        LEFT JOIN
            PERSON_EXT_ATTRS oldSystemId
        ON
            oldSystemId.PERSONCENTER = SU.OWNER_CENTER
            AND oldSystemId.PERSONID = SU.OWNER_ID
            AND oldSystemId.NAME = '_eClub_OldSystemPersonId'
        LEFT JOIN
            (
                SELECT
                    cc.PERSONCENTER,
                    cc.PERSONID
                FROM
                    CASHCOLLECTIONCASES cc
                CROSS JOIN
                    params
                WHERE
                    cc.MISSINGPAYMENT = 0
                    AND cc.STARTDATE < params.CutDateAsDate + 1
                    AND (
                        cc.CLOSED = 0
                        OR (
                            cc.CLOSED = 1
                            AND cc.CLOSED_DATETIME > params.CutDateAsLong + (1000*60*60*24)))) memberAgreementCase
        ON
            memberAgreementCase.PERSONCENTER = SU.OWNER_CENTER
            AND memberAgreementCase.PERSONID = SU.OWNER_ID
        LEFT JOIN
            (
                SELECT
                    op_rel.RELATIVECENTER,
                    op_rel.RELATIVEID,
                    op_rel.CENTER payerCenter,
                    op_rel.ID payerId
                FROM
                    CASHCOLLECTIONCASES cc
                CROSS JOIN
                    params
                JOIN
                    RELATIVES op_rel
                ON
                    op_rel.CENTER = CC.PERSONCENTER
                    AND op_rel.ID = CC.PERSONID
                    AND op_rel.RTYPE = 12
                    --AND op_rel.STATUS < 3
                JOIN
                    STATE_CHANGE_LOG scl
                ON
                    scl.CENTER = op_rel.CENTER
                    AND scl.ID = op_rel.ID
                    AND scl.SUBID = op_rel.SUBID
                    AND scl.ENTRY_TYPE = 4
                    AND scl.STATEID < 3
                    AND scl.ENTRY_START_TIME < params.CutDateAsLong + (1000*60*60*24)
                    AND (
                        scl.ENTRY_END_TIME IS NULL
                        OR scl.ENTRY_END_TIME > params.CutDateAsLong + (1000*60*60*24))
                WHERE
                    cc.MISSINGPAYMENT = 0
                    AND cc.STARTDATE < params.CutDateAsDate + 1
                    AND (
                        cc.CLOSED = 0
                        OR (
                            cc.CLOSED = 1
                            AND cc.CLOSED_DATETIME > params.CutDateAsLong + (1000*60*60*24)))) opAgreementCase
        ON
            opAgreementCase.RELATIVECENTER = SU.OWNER_CENTER
            AND opAgreementCase.RELATIVEID = SU.OWNER_ID
        WHERE
            (
                SU.CENTER IN ($$Scope$$) ) )
GROUP BY
    OWNER_CENTER ,
    subscriptionId,
    personId,
    startdate,
    enddate,
    creation,
    pgName,
    SUB_CENTER,
    SUB_ID
                            /********************* END WD1 ***************************/
                            )i1
                            /* Do a left join to filter out the ones that are NOT in LIVE_CLOSING or are NOT comming
                            back from freeze in month after cutdate or the first of the month after the month after the
                            cut date */
                        LEFT JOIN
                            SUBSCRIPTION_FREEZE_PERIOD sfp
                        ON
                            (
                                /* Only look at failing LIVE_CLOSING to simplify */
                                i1.LIVE_CLOSING = 0
                                AND sfp.STATE = 'ACTIVE'
                                AND sfp.SUBSCRIPTION_CENTER = i1.SUB_CENTER
                                AND sfp.SUBSCRIPTION_ID = i1.SUB_ID
                                /* So if the cut date is 2015-08-31 all with ending freezes in Month 9 and day 2015-10-
                                01 should be included */
                                AND sfp.END_DATE BETWEEN exerpro.longtodateTZ($$CutDate$$, 'Europe/London') + 1 AND
                                add_months(exerpro.longtodateTZ($$CutDate$$, 'Europe/London') + 1,1) )
                            /* All that are in LIVE_CLOSING should just pass */
                            /* This is to filter out the members that will be in state FROZEN end of month after cut
                            date and first day in the folowing month, e.g. frozen during 2015-09-30 and 2015-10-01 */
                        LEFT JOIN
                            SUBSCRIPTION_FREEZE_PERIOD sfp2
                        ON
                            sfp2.SUBSCRIPTION_CENTER = i1.sub_center
                            AND sfp2.SUBSCRIPTION_ID = i1.SUB_ID
                            AND sfp2.STATE = 'ACTIVE'
                            AND ((
                                    add_months(exerpro.longtodateTZ($$CutDate$$, 'Europe/London'),1) BETWEEN
                                    sfp2.START_DATE AND sfp2.END_DATE)
                                AND (
                                    add_months(exerpro.longtodateTZ($$CutDate$$, 'Europe/London') + 1,1) BETWEEN
                                    sfp2.START_DATE AND sfp2.END_DATE))
                        JOIN
                            SUBSCRIPTIONS s
                        ON
                            s.CENTER = i1.sub_center
                            AND s.ID = i1.sub_id
                            /* Three centers that should be excluded */
                            AND s.center NOT IN (4,430,431)
                            /* Pick up any cash collection cases started after the cut date */
                        JOIN
                            SUBSCRIPTIONTYPES st
                        ON
                            st.CENTER = s.SUBSCRIPTIONTYPE_CENTER
                            AND st.ID = s.SUBSCRIPTIONTYPE_ID
                        JOIN
                            PRODUCTS prod
                        ON
                            prod.CENTER = s.SUBSCRIPTIONTYPE_CENTER
                            AND prod.ID = s.SUBSCRIPTIONTYPE_ID
        left join PRODUCT_AND_PRODUCT_GROUP_LINK pg_link on pg_link.PRODUCT_CENTER = prod.CENTER and pg_link.PRODUCT_ID = prod.ID
        left join PRODUCT_GROUP tpg ON tpg.ID = pg_link.PRODUCT_GROUP_ID AND  tpg.NAME = 'Temporary Memberships'                  
                        JOIN
                            PRODUCT_GROUP pg
                        ON
                            pg.id = prod.PRIMARY_PRODUCT_GROUP_ID
                            /*
                            Filtering out:
                            Mem Cat: Complimentary
                            Exclude from Member Count
                            Legacy Subscriptions (HO only)
                            */
                            AND pg.id NOT IN (5405,219,244,4601)
                        LEFT JOIN
                            (
                                SELECT
                                    cc.PERSONCENTER,
                                    cc.PERSONID,
                                    cc.STARTDATE,
                                    cc.amount
                                FROM
                                    CASHCOLLECTIONCASES cc
                                JOIN
                                    ACCOUNT_RECEIVABLES ar
                                ON
                                    ar.CUSTOMERCENTER = cc.PERSONCENTER
                                    AND ar.CUSTOMERID = cc.PERSONID
                                    AND ar.AR_TYPE = 4
                                    AND ar.BALANCE < 0
                                WHERE
                                    cc.MISSINGPAYMENT = 1
                                    AND cc.STARTDATE > exerpro.longtodateTZ($$CutDate$$, 'Europe/London')
                                    AND cc.CLOSED = 0 ) debtCase
                        ON
                            debtCase.PERSONCENTER = s.OWNER_CENTER
                            AND debtCase.PERSONID = s.OWNER_ID
                            /* Pick up any missing agreement case started after the cut date */
                        LEFT JOIN
                            (
                                SELECT
                                    cc.PERSONCENTER,
                                    cc.PERSONID,
                                    cc.STARTDATE
                                FROM
                                    CASHCOLLECTIONCASES cc
                                JOIN
                                    ACCOUNT_RECEIVABLES ar
                                ON
                                    ar.CUSTOMERCENTER = cc.PERSONCENTER
                                    AND ar.CUSTOMERID = cc.PERSONID
                                    AND ar.AR_TYPE = 4
                                    AND ar.BALANCE < 0
                                WHERE
                                    cc.MISSINGPAYMENT = 0
                                    AND cc.STARTDATE > exerpro.longtodateTZ($$CutDate$$, 'Europe/London')
                                    AND cc.CLOSED = 0 ) agreementCase
                        ON
                            agreementCase.PERSONCENTER = s.OWNER_CENTER
                            AND agreementCase.PERSONID = s.OWNER_ID
                        LEFT JOIN
                            (
                                SELECT
                                    futSub.START_DATE,
                                    futSub.OWNER_CENTER,
                                    futSub.OWNER_ID
                                FROM
                                    SUBSCRIPTIONS futSub
                                WHERE
                                    futSub.STATE IN (2,4,8)
                                    AND futSub.START_DATE >= TRUNC(exerpro.longtodateTZ($$CutDate$$, 'Europe/London'),
                                    'mm') ) futureSub
                        ON
                            futureSub.OWNER_CENTER = s.OWNER_CENTER
                            AND futureSub.OWNER_ID = s.OWNER_ID
                            AND futureSub.START_DATE >= s.END_DATE
                            AND futureSub.START_DATE <= add_months(TRUNC(exerpro.longtodateTZ($$CutDate$$, 'Europe/London'), 'mm'),2))
                    /********************* DRAFT 2 PART BEGIN **************************/
            ) i2
        JOIN
            SUBSCRIPTIONS s
        ON
            s.CENTER = i2.sub_center
            AND s.ID = i2.sub_id
        JOIN
            PRODUCTS prod
        ON
            prod.CENTER = s.SUBSCRIPTIONTYPE_CENTER
            AND prod.ID = s.SUBSCRIPTIONTYPE_ID
        JOIN
            PRODUCT_GROUP pg
        ON
            pg.ID = prod.PRIMARY_PRODUCT_GROUP_ID
        JOIN
            PERSONS p
        ON
            p.CENTER = s.OWNER_CENTER
            AND p.id = s.OWNER_ID
        JOIN
            CENTERS c
        ON
            c.id = p.CENTER
            /***************** BEGIN QUESTIONNAIRES LOGIC ************************/
        LEFT JOIN
            JOURNALENTRIES je
        ON
            je.PERSON_CENTER = s.OWNER_CENTER
            AND je.PERSON_ID = s.OWNER_ID
            AND je.JETYPE = 18
            AND je.REF_CENTER = s.CENTER
            AND je.REF_ID = s.ID
        LEFT JOIN
            QUESTIONNAIRE_ANSWER QUN
        ON
            QUN.CENTER = s.OWNER_CENTER
            AND QUN.ID = s.OWNER_ID
        LEFT JOIN
            question_answer qa
        ON
            qa.ANSWER_CENTER = qun.center
            AND qa.ANSWER_ID = qun.id
            AND qa.ANSWER_SUBID = qun.subid
        LEFT JOIN
            QUESTIONNAIRE_CAMPAIGNS QC
        ON
            QC.ID = QUN.QUESTIONNAIRE_CAMPAIGN_ID
            AND QC.TYPE = 3
            --AND exerpro.longToDate(qun.LOG_TIME) BETWEEN QC.STARTDATE AND QC.STOPDATE
            AND exerpro.longToDate(je.CREATION_TIME) BETWEEN QC.STARTDATE AND QC.STOPDATE
            AND QC.SCOPE_TYPE = 'A'
        LEFT JOIN
            QUESTIONNAIRES Q
        ON
            q.ID = QC.QUESTIONNAIRE
            /***************** END QUESTIONNAIRES LOGIC ************************/
        WHERE
            i2.SHOWS_IN_ETR > 0
        GROUP BY
            c.SHORTNAME ,
            p.CENTER,
            p.ID ,
            floor(months_between(TRUNC(SYSDATE),p.BIRTHDATE)/12) ,
            p.FIRSTNAME ,
            p.LASTNAME ,
            s.CENTER ,
            s.ID ,
            prod.NAME ,
            CASH_TO_INCLUDE,
            pg.NAME ,
            DECODE(i2.CASH_TO_INCLUDE,1,'Subscription Ended/','') || DECODE(i2.ENDING_SUB,1,'Subscription Ended/','')
            || DECODE (i2.NEW_DEBT_CASE,1,'Debt Case/','') || DECODE(i2.ENTERING_FREEZE,1,'Freeze/','') || DECODE
            (i2.NEW_AGREEMENT_CASE,1 ,'DDI Case/',''),
            i2.ENDING_SUB_END_DATE ,
            i2.DEBT_CASE_AMOUNT ,
            i2.NEW_AGREEMENT_CASE_START_DATE ,
            i2.COMING_OUT_OF_FREEZE ,
            i2.ENTERING_FREEZE_START_DATE ,
            i2.ENTERING_FREEZE_END_DATE ,
            ENTERING_FREEZE ,
            ENTERING_FREEZE_START_DATE ,
            ENTERING_FREEZE_END_DATE ,
            s.BINDING_END_DATE ) i3