SELECT
    *
FROM
    (
        SELECT
                    CASE
                        WHEN (LIVE_CLOSING = 1
                                OR COMING_OUT_OF_FREEZE = 1)
                            AND (ENTERING_FREEZE = 1
                                OR ENDING_SUB = 1
                                OR NEW_DEBT_CASE = 1
                                OR NEW_AGREEMENT_CASE = 1 )
                        THEN 1
                        ELSE 0
                    END AS SHOWS_IN_ETR,
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
            NEW_DEBT_CASE,
            NEW_DEBT_CASE_START_DATE,
            NEW_AGREEMENT_CASE,
            NEW_AGREEMENT_CASE_START_DATE
        FROM
            (
                SELECT
                    i1.SUB_CENTER,
                    i1.SUB_ID,
                    i1.LIVE_CLOSING,
                    CASE
                        WHEN sfp.START_DATE IS NOT NULL
                            AND sfp.END_DATE BETWEEN exerpro.longtodateTZ($$CutDate$$, 'Europe/London') + 1 AND add_months(exerpro.longtodateTZ($$CutDate$$, 'Europe/London') + 1,1)
                        THEN 1
                        ELSE 0
                    END            AS COMING_OUT_OF_FREEZE,
                    sfp.START_DATE    COMING_OFF_FREEZE_START,
                    sfp.END_DATE      COMING_OFF_FREEZE_END,
                    CASE
                        WHEN sfp2.START_DATE IS NOT NULL
                            AND (( add_months(exerpro.longtodateTZ($$CutDate$$, 'Europe/London'),1) BETWEEN sfp2.START_DATE AND sfp2.END_DATE)
                                AND ( add_months(exerpro.longtodateTZ($$CutDate$$, 'Europe/London') + 1,1) BETWEEN sfp2.START_DATE AND sfp2.END_DATE))
                        THEN 1
                        ELSE 0
                    END             AS ENTERING_FREEZE,
                    sfp2.START_DATE    ENTERING_FREEZE_START_DATE,
                    sfp2.END_DATE      ENTERING_FREEZE_END_DATE,
                    CASE
                        WHEN s.END_DATE IS NOT NULL
                            AND s.END_DATE BETWEEN exerpro.longtodateTZ($$CutDate$$, 'Europe/London') + 1 AND add_months(exerpro.longtodateTZ($$CutDate$$, 'Europe/London') + 1,1)
                            AND s.SUB_STATE = 1
                        THEN 1
                        ELSE 0
                    END                                                                                                                                                                     AS ENDING_SUB,
                    s.END_DATE                                                                                                                                                                 ENDING_SUB_END_DATE,
                    DECODE (s.SUB_STATE, 1,'NONE', 2,'AWAITING_ACTIVATION', 3,'UPGRADED', 4,'DOWNGRADED', 5,'EXTENDED', 6, 'TRANSFERRED',7,'REGRETTED',8,'CANCELLED',9,'BLOCKED','UNKNOWN') AS ENDING_SUB_SUB_STATE,
                    nvl2(debtCase.startdate,1,0)                                                                                                                                               NEW_DEBT_CASE,
                    debtCase.startdate                                                                                                                                                         NEW_DEBT_CASE_START_DATE,
                    nvl2(agreementCase.startdate,1,0)                                                                                                                                          NEW_AGREEMENT_CASE,
                    agreementCase.startdate                                                                                                                                                    NEW_AGREEMENT_CASE_START_DATE
                FROM
                    (
                        /* Begin by just adding all data from WD1, LIVE_CLOSING or not */
                        SELECT DISTINCT
                            SUB_CENTER,
                            SUB_ID,
                            personid || ', ' || subscriptionId id,
                            OWNER_CENTER                       CENTER,
                            personId,
                            startdate,
                            enddate,
                            creation,
                            pgName,
                            SUM(ACTIVE_CLOSING)                                                                                                                       ACTIVE_CLOSING,
                            SUM(BLOCKED)                                                                                                                              BLOCKED,
                            SUM(FROZEN)                                                                                                                               FROZEN,
                            SUM(MISSING_AGREEMENT)                                                                                                                    MISSING_DDI,
                            SUM(WINDOW)                                                                                                                               WINDOW,
                            SUM(DEFERRED_ONE_MONTH)                                                                                                                   DEFERRED_ONE_MONTH,
                            SUM(DEFERRED_TWO_MONTHS)                                                                                                                  DEFERRED_TWO_MONTHS,
                            SUM(DEFERRED_LATER)                                                                                                                       DEFERRED_LATER,
                            SUM(ACTIVE_CLOSING) + SUM(BLOCKED) + SUM(MISSING_AGREEMENT) + SUM(FROZEN) + SUM(DEFERRED_TWO_MONTHS) + SUM (DEFERRED_LATER) + SUM(WINDOW) LIVE_CLOSING
                        FROM
                            (
                                SELECT
                                    SU.CENTER SUB_CENTER,
                                    SU.ID     SUB_ID,
                                    SU.OWNER_CENTER,
                                    SU.OWNER_ID,
                                    SU.OWNER_CENTER || 'p' || SU.OWNER_ID                                                       personId,
                                    SU.CENTER || 'ss' || SU.ID                                                                  subscriptionId,
                                    PG.NAME                                                                                     pgName,
                                    TO_CHAR(SU.START_DATE, 'YYYY-MM-DD')                                                        STARTDATE,
                                    TO_CHAR(SU.END_DATE, 'YYYY-MM-DD')                                                          ENDDATE,
                                    TO_CHAR(exerpro.longtodateTZ(SU.CREATION_TIME, 'Europe/London'), 'YYYY-MM-DD')              CREATION,
                                    TO_CHAR(exerpro.longtodateTZ(SCL1.ENTRY_START_TIME, 'Europe/London'), 'YYYY-MM-DD HH24:MI') ENTRY_START,
                                    TO_CHAR(exerpro.longtodateTZ(SCL1.ENTRY_END_TIME, 'Europe/London'), 'YYYY-MM-DD HH24:MI')   ENTRY_END ,
                                    CASE
                                        WHEN SCL1.STATEID IN (2,4,8)
                                        THEN 1
                                        ELSE 0
                                    END ACTIVE_CLOSING,
                                    CASE
                                        WHEN SCL1.STATEID IN (9)
                                            OR SU.SUB_STATE IN (9)
                                        THEN -1
                                        ELSE 0
                                    END BLOCKED,
                                    CASE
                                        WHEN SCL1.STATEID IN (4)
                                            AND SU.SUB_STATE NOT IN (9)
                                            AND SCL1.STATEID NOT IN (9)
                                        THEN -1
                                        ELSE 0
                                    END FROZEN,
                                    CASE
                                        WHEN SCL1.STATEID IN (2,4,8)
                                            AND (memberAgreementCase.PERSONCENTER IS NOT NULL
                                                OR opAgreementCase.RELATIVECENTER IS NOT NULL)
                                            AND SCL1.STATEID NOT IN (4)
                                            AND SU.SUB_STATE NOT IN (9)
                                            AND SCL1.STATEID NOT IN (9)
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
                                            AND SU.SUB_STATE NOT IN (9)
                                            AND SCL1.STATEID NOT IN (9)
                                            AND memberAgreementCase.PERSONCENTER IS NULL
                                            AND opAgreementCase.RELATIVECENTER IS NULL
                                        THEN 1
                                        ELSE 0
                                    END WINDOW,
                                    CASE
                                        WHEN SCL1.STATEID IN (8)
                                            AND SU.SUB_STATE NOT IN (9)
                                            AND SCL1.STATEID NOT IN (9)
                                            AND memberAgreementCase.PERSONCENTER IS NULL
                                            AND opAgreementCase.RELATIVECENTER IS NULL
                                            AND SU.START_DATE <= add_months(exerpro.longtodate($$CutDate$$),1)
                                        THEN -1
                                        ELSE 0
                                    END DEFERRED_ONE_MONTH,
                                    CASE
                                        WHEN SCL1.STATEID IN (8)
                                            AND SU.SUB_STATE NOT IN (9)
                                            AND SCL1.STATEID NOT IN (9)
                                            AND memberAgreementCase.PERSONCENTER IS NULL
                                            AND opAgreementCase.RELATIVECENTER IS NULL
                                            AND SU.START_DATE > add_months(exerpro.longtodate($$CutDate$$),1)
                                            AND SU.START_DATE <= add_months(exerpro.longtodate($$CutDate$$),2)
                                        THEN -1
                                        ELSE 0
                                    END DEFERRED_TWO_MONTHS,
                                    CASE
                                        WHEN SCL1.STATEID IN (8)
                                            AND SU.SUB_STATE NOT IN (9)
                                            AND SCL1.STATEID NOT IN (9)
                                            AND memberAgreementCase.PERSONCENTER IS NULL
                                            AND opAgreementCase.RELATIVECENTER IS NULL
                                            AND SU.START_DATE > add_months(exerpro.longtodate($$CutDate$$),2)
                                        THEN -1
                                        ELSE 0
                                    END DEFERRED_LATER,
                                    perCreation.txtvalue "Original joined date",
                                    oldSystemId.txtvalue "Old System Id"
                                FROM
                                    SUBSCRIPTIONS SU
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
                                        AND SCL1.BOOK_START_TIME < $$CutDate$$ + (1000*60*60*24) + 2000
                                        AND SCL1.ENTRY_START_TIME < $$CutDate$$ + (1000*60*60*30) )
                                    AND (
                                        SCL1.ENTRY_END_TIME IS NULL
                                        OR SCL1.ENTRY_END_TIME > $$CutDate$$ + (1000*60*60*30) )
                                INNER JOIN
                                    PRODUCTS PR
                                ON
                                    (
                                        ST.CENTER = PR.CENTER
                                        AND ST.ID = PR.ID )
                                JOIN
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
                                        JOIN
                                            ACCOUNT_RECEIVABLES ar
                                        ON
                                            ar.CUSTOMERCENTER = cc.PERSONCENTER
                                            AND ar.CUSTOMERID = cc.PERSONID
                                            AND ar.AR_TYPE = 4
                                            AND ar.BALANCE < 0
                                        WHERE
                                            cc.MISSINGPAYMENT = 0
                                            AND cc.STARTDATE < exerpro.longtodateTZ($$CutDate$$, 'Europe/London') + 1
                                            AND cc.CLOSED = 0 ) memberAgreementCase
                                ON
                                    memberAgreementCase.PERSONCENTER = SU.OWNER_CENTER
                                    AND memberAgreementCase.PERSONID = Su.OWNER_ID
                                LEFT JOIN
                                    (
                                        SELECT
                                            op_rel.RELATIVECENTER,
                                            op_rel.RELATIVEID
                                        FROM
                                            CASHCOLLECTIONCASES cc
                                        JOIN
                                            ACCOUNT_RECEIVABLES ar
                                        ON
                                            ar.CUSTOMERCENTER = cc.PERSONCENTER
                                            AND ar.CUSTOMERID = cc.PERSONID
                                            AND ar.AR_TYPE = 4
                                            AND ar.BALANCE < 0
                                        JOIN
                                            RELATIVES op_rel
                                        ON
                                            op_rel.CENTER = CC.PERSONCENTER
                                            AND op_rel.ID = CC.PERSONID
                                            AND op_rel.RTYPE = 12
                                            AND op_rel.STATUS < 3
                                        WHERE
                                            cc.MISSINGPAYMENT = 0
                                            AND cc.STARTDATE < exerpro.longtodateTZ($$CutDate$$, 'Europe/London') + 1
                                            AND cc.CLOSED = 0 ) opAgreementCase
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
                            SUB_ID )i1
                    /* Do a left join to filter out the ones that are NOT in LIVE_CLOSING or are NOT comming back from freeze in month after cutdate or the first of the month after the month after the cut date */
                LEFT JOIN
                    SUBSCRIPTION_FREEZE_PERIOD sfp
                ON
                    (
                        /* Only look at failing LIVE_CLOSING to simplify */
                        i1.LIVE_CLOSING = 0
                        AND sfp.STATE = 'ACTIVE'
                        AND sfp.SUBSCRIPTION_CENTER = i1.SUB_CENTER
                        AND sfp.SUBSCRIPTION_ID = i1.SUB_ID
                        /* So if the cut date is 2015-08-31 all with ending freezes in Month 9 and day 2015-10-01 should be included */
                        AND sfp.END_DATE BETWEEN exerpro.longtodateTZ($$CutDate$$, 'Europe/London') + 1 AND add_months(exerpro.longtodateTZ($$CutDate$$, 'Europe/London') + 1,1) )
                    /* All that are in LIVE_CLOSING should just pass */
                    /* This is to filter out the members that will be in state FROZEN end of month after cut date and first day in the folowing month, e.g. frozen during 2015-09-30 and 2015-10-01 */
                LEFT JOIN
                    SUBSCRIPTION_FREEZE_PERIOD sfp2
                ON
                    sfp2.SUBSCRIPTION_CENTER = i1.sub_center
                    AND sfp2.SUBSCRIPTION_ID = i1.SUB_ID
                    AND sfp2.STATE = 'ACTIVE'
                    AND ((
                            add_months(exerpro.longtodateTZ($$CutDate$$, 'Europe/London'),1) BETWEEN sfp2.START_DATE AND sfp2.END_DATE)
                        AND (
                            add_months(exerpro.longtodateTZ($$CutDate$$, 'Europe/London') + 1,1) BETWEEN sfp2.START_DATE AND sfp2.END_DATE))
                JOIN
                    SUBSCRIPTIONS s
                ON
                    s.CENTER = i1.sub_center
                    AND s.ID = i1.sub_id
                    /* Pick up any cash collection cases started after the cut date */
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
                    AND agreementCase.PERSONID = s.OWNER_ID ) )
WHERE
    SHOWS_IN_ETR > $$ETR$$