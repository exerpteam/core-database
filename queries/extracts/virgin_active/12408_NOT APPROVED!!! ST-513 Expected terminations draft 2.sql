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
				WHEN CASH_TO_INCLUDE = 1 THEN 1
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
            NEW_AGREEMENT_CASE_START_DATE,
			CASH_TO_INCLUDE
        FROM
            (
                SELECT
                    CASE
                        WHEN i1.WINDOW = 1 and s.SUB_STATE = 1 and st.ST_TYPE = 0
                        THEN 1
                        ELSE 0
                    END as CASH_TO_INCLUDE,
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
                    agreementCase.startdate                                                                                                                                                    NEW_AGREEMENT_CASE_START_DATE,
                    i1.WINDOW                        
                FROM
                    (
                        /********************* START WD1 ***************************/
                        !!extract 11605!!
                            /********************* END WD1 ***************************/
                    )i1
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
					/* Three centers that should be excluded */
					and s.center not in (4,430,431)
                    /* Pick up any cash collection cases started after the cut date */
                join SUBSCRIPTIONTYPES st on st.CENTER = s.SUBSCRIPTIONTYPE_CENTER and st.ID = s.SUBSCRIPTIONTYPE_ID    
                join PRODUCTS prod on prod.CENTER = s.SUBSCRIPTIONTYPE_CENTER and prod.ID = s.SUBSCRIPTIONTYPE_ID
                join PRODUCT_GROUP pg on pg.id = prod.PRIMARY_PRODUCT_GROUP_ID 
				/* 
Filtering out:
Mem Cat: Complimentary
Exclude from Member Count
Legacy Subscriptions (HO only)	
				*/
				and pg.id not in (5405,219,244,4601)   
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