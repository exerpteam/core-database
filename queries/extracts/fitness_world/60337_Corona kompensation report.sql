-- The extract is extracted from Exerp on 2026-02-08
--  
SELECT
    ar.CUSTOMERCENTER||'p'||ar.CUSTOMERID AS "Member ID",
    ar.BALANCE                            AS "Cash Account Balance",
    ar2.BALANCE                           AS "External Debt Account Balance",
    ar3.BALANCE                           AS "Payment Account Balance"
FROM
    FW.ACCOUNT_RECEIVABLES ar
JOIN
    FW.AR_TRANS art
ON
    art.CENTER = ar.CENTER
    AND art.ID = ar.ID
    AND ar.AR_TYPE = 1
    AND art.TEXT = 'Corona kompensation'
LEFT JOIN
    FW.ACCOUNT_RECEIVABLES ar2
ON
    ar2.CUSTOMERCENTER = ar.CUSTOMERCENTER
    AND ar2.CUSTOMERID = ar.CUSTOMERID
    AND ar2.AR_TYPE = 5
    AND ar2.STATE = 0
LEFT JOIN
    FW.ACCOUNT_RECEIVABLES ar3
ON
    ar3.CUSTOMERCENTER = ar.CUSTOMERCENTER
    AND ar3.CUSTOMERID = ar.CUSTOMERID
    AND ar3.AR_TYPE = 4
WHERE
     ar2.center IS NOT NULL
     and ar.CUSTOMERCENTER in (:scope)