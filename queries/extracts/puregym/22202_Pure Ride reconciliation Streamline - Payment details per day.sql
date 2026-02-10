-- The extract is extracted from Exerp on 2026-02-08
--  
SELECT
    TO_CHAR(longtodateTZ(act.TRANS_TIME, 'Europe/London'),'DD/MM/YYYY HH24:MI:SS') AS "DATETIME",
    acc.name                                                                       AS account,
    CASE
        WHEN (art.amount<0)
        THEN art.amount
        ELSE 0
    END                                     AS REFUND ,
    p.fullname                              AS Name,
    act.TEXT                                AS "Transaction Text",
    art.INFO                                AS "Transaction ID",
    ar.CUSTOMERCENTER|| 'p'|| ar.CUSTOMERID AS PersonId,
	ar.CUSTOMERCENTER 						AS ClubId,
    CASE
        WHEN (art.amount>0)
        THEN art.amount
        ELSE 0
    END                                                                            AS PAYMENT,
    TO_CHAR(longtodateTZ(act.ENTRY_TIME, 'Europe/London'),'DD/MM/YYYY HH24:MI:SS') AS "ENTRYTIME"
FROM
    PUREGYM.ACCOUNTS acc
JOIN
    PUREGYM.ACCOUNT_TRANS act
ON
    (
        act.DEBIT_ACCOUNTCENTER = acc.center
        AND act.DEBIT_ACCOUNTID = acc.id )
    OR (
        act.CREDIT_ACCOUNTCENTER = acc.center
        AND act.CREDIT_ACCOUNTID = acc.id )
JOIN
    PUREGYM.AR_TRANS art
ON
    art.REF_TYPE = 'ACCOUNT_TRANS'
    AND art.REF_CENTER = act.center
    AND art.REF_ID = act.id
    AND art.REF_SUBID = act.subid
JOIN
    PUREGYM.ACCOUNT_RECEIVABLES AR
ON
    AR.CENTER = art.CENTER
    AND AR.ID = ART.ID
JOIN
    PERSONS P
ON
    P.CENTER = AR.CUSTOMERCENTER
    AND P.ID = AR.CUSTOMERID
WHERE
    act.AMOUNT <> 0
    AND acc.globalid = 'BANK_ACCOUNT_PURERIDE_WEB'						 
    AND act.TRANS_TIME >= $$fromdate$$
    AND act.TRANS_TIME < $$todate$$ + 24*3600*1000
ORDER BY
    "DATETIME"