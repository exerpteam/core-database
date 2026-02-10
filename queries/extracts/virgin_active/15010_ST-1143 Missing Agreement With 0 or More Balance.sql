-- The extract is extracted from Exerp on 2026-02-08
--  
WITH
    params AS
    (
        SELECT
            CURRENT_DATE AS CutDateAsDate,
            CAST(datetolongtz(TO_CHAR(CURRENT_DATE,'YYYY-MM-DD HH24:MI'), 'Europe/London') AS bigint) AS CutDateAsLong
    )
    ,
	 params2 AS
    (
        SELECT
            CURRENT_DATE AS CutDateAsDate,
            CAST(datetolongtz(TO_CHAR(CURRENT_DATE,'YYYY-MM-DD HH24:MI'), 'Europe/London') AS bigint) AS CutDateAsLong
    )
	,
	params3 AS
    (
        SELECT
            CURRENT_DATE AS CutDateAsDate,
            CAST(datetolongtz(TO_CHAR(CURRENT_DATE,'YYYY-MM-DD HH24:MI'), 'Europe/London') AS bigint) AS CutDateAsLong
    )
	,
	params4 AS
    (
        SELECT
            CURRENT_DATE AS CutDateAsDate,
            CAST(datetolongtz(TO_CHAR(CURRENT_DATE,'YYYY-MM-DD HH24:MI'), 'Europe/London') AS bigint) AS CutDateAsLong
    )
    ,
    memberBalance AS
    (
        SELECT
            MAX (ar.CUSTOMERCENTER)                     CUSTOMERCENTER,
            MAX (ar.CUSTOMERID)                         CUSTOMERID,
            ar.BALANCE - SUM(COALESCE(art.AMOUNT,0)) AS BALANCEATCUTDATE
        FROM
            ACCOUNT_RECEIVABLES ar
        CROSS JOIN
            params
        LEFT JOIN
            AR_TRANS art
        ON
            art.CENTER = ar.CENTER
        AND art.ID = ar.ID
        AND art.ENTRY_TIME >= params.CutDateAsLong
        WHERE
            ar.AR_TYPE = 4
        AND ar.center IN ($$scope$$)
        GROUP BY
            ar.CENTER,
            ar.ID,
            ar.AR_TYPE,
            ar.CUSTOMERCENTER,
            ar.CUSTOMERID,
            ar.BALANCE
        HAVING
            ar.BALANCE - SUM(COALESCE(art.AMOUNT,0)) >= 0
    )
    ,
    opAgreementCase AS
    (
        SELECT
            op_rel.RELATIVECENTER,
            op_rel.RELATIVEID,
            op_rel.CENTER PAYERCENTER,
            op_rel.ID     PAYERID,
            cc.STARTDATE
        FROM
            CASHCOLLECTIONCASES cc
        CROSS JOIN
            params2 params
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
            OR  scl.ENTRY_END_TIME > params.CutDateAsLong + (1000*60*60*24))
        WHERE
            cc.MISSINGPAYMENT = 0
        AND cc.STARTDATE < params.CutDateAsDate + 1
        AND (
                cc.CLOSED = 0
            OR  (
                    cc.CLOSED = 1
                AND cc.CLOSED_DATETIME > params.CutDateAsLong + (1000*60*60*24)))
        AND cc.center IN ($$scope$$)
    )
    ,
    opBalance AS
    (
        SELECT
            MAX (ar.CUSTOMERCENTER)                     CUSTOMERPAYERCENTER,
            MAX (ar.CUSTOMERID)                         CUSTOMERPAYERID,
            ar.BALANCE - SUM(COALESCE(art.AMOUNT,0)) AS BALANCEATCUTDATE
        FROM
            ACCOUNT_RECEIVABLES ar
        CROSS JOIN
            params3 params
        LEFT JOIN
            AR_TRANS art
        ON
            art.CENTER = ar.CENTER
        AND art.ID = ar.ID
        AND art.ENTRY_TIME >= params.CutDateAsLong
        WHERE
            ar.AR_TYPE = 4
        AND ar.center IN ($$scope$$)
        GROUP BY
            ar.CENTER,
            ar.ID,
            ar.AR_TYPE,
            ar.CUSTOMERCENTER,
            ar.CUSTOMERID,
            ar.BALANCE
        HAVING
            ar.BALANCE - SUM(COALESCE(art.AMOUNT,0)) >= 0
    )
    ,
    t1 AS
    (
        SELECT
            su.OWNER_CENTER,
            su.OWNER_ID,
            cp.EXTERNAL_ID,
            COALESCE(memberAgreementCase.STARTDATE, opAgreementCase.STARTDATE) STARTDATE ,
            memberBalance.BALANCEATCUTDATE                                     MEMBERBALANCE,
            opBalance.BALANCEATCUTDATE                                         OPBALANCE
        FROM
            SUBSCRIPTIONS su
        CROSS JOIN
            params4 params
        INNER JOIN
            PERSONS p
        ON
            p.CENTER = su.OWNER_CENTER
        AND p.ID = su.OWNER_ID
        JOIN
            PERSONS cp
        ON
            cp.CENTER = p.CURRENT_PERSON_CENTER
        AND cp.ID = p.CURRENT_PERSON_ID
        INNER JOIN
            SUBSCRIPTIONTYPES st
        ON
            (
                su.SUBSCRIPTIONTYPE_CENTER = st.CENTER
            AND su.SUBSCRIPTIONTYPE_ID = st.ID )
        INNER JOIN
            STATE_CHANGE_LOG scl1
        ON
            (
                scl1.CENTER = su.CENTER
            AND scl1.ID = su.ID
            AND scl1.ENTRY_TYPE = 2
            AND scl1.STATEID IN (2,4,7,8)
            AND scl1.BOOK_START_TIME < params.CutDateAsLong + (1000*60*60*24) + 2000
            AND scl1.ENTRY_START_TIME < params.CutDateAsLong + (1000*60*60*33) )
        AND (
                scl1.ENTRY_END_TIME IS NULL
            OR  scl1.ENTRY_END_TIME > params.CutDateAsLong + (1000*60*60*33) )
        LEFT JOIN
            CASHCOLLECTIONCASES memberAgreementCase
        ON
            memberAgreementCase.PERSONCENTER = su.OWNER_CENTER
        AND memberAgreementCase.PERSONID = su.OWNER_ID
        AND memberAgreementCase.MISSINGPAYMENT = 0
        AND memberAgreementCase.STARTDATE < params.CutDateAsDate + 1
        AND (
                memberAgreementCase.CLOSED = 0
            OR  (
                    memberAgreementCase.CLOSED = 1
                AND memberAgreementCase.CLOSED_DATETIME > params.CutDateAsLong + (1000*60*60*24)))
        LEFT JOIN
            opAgreementCase
        ON
            opAgreementCase.RELATIVECENTER = su.OWNER_CENTER
        AND opAgreementCase.RELATIVEID = su.OWNER_ID
        LEFT JOIN
            memberBalance
        ON
            memberBalance.CUSTOMERCENTER = memberAgreementCase.PERSONCENTER
        AND memberBalance.CUSTOMERID = memberAgreementCase.PERSONID
        LEFT JOIN
            opBalance
        ON
            opBalance.CUSTOMERPAYERCENTER = opAgreementCase.PAYERCENTER
        AND opBalance.CUSTOMERPAYERID = opAgreementCase.PAYERID
        WHERE
            (
                su.CENTER IN ($$scope$$)
            AND scl1.STATEID IN (2,4,8)
            AND scl1.STATEID NOT IN (4)
            AND scl1.SUB_STATE NOT IN (9)
            AND ( (
                        memberAgreementCase.PERSONCENTER IS NOT NULL
                    AND memberBalance.CUSTOMERCENTER IS NOT NULL )
                OR  (
                        opAgreementCase.RELATIVECENTER IS NOT NULL
                    AND opBalance.CUSTOMERPAYERCENTER IS NOT NULL ) ) )
    )
SELECT
    EXTERNAL_ID                     AS "PERSON_ID",
    MAX(STARTDATE)                  AS "MISSING_DDI_STARTDATE",
    SUM(COALESCE(MEMBERBALANCE, 0)) AS "MEMBER_BALANCE",
    SUM(COALESCE(OPBALANCE, 0))     AS "OTHER_PAYER_BALANCE"
FROM
    t1
GROUP BY
    EXTERNAL_ID