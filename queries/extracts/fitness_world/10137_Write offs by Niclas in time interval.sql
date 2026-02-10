-- The extract is extracted from Exerp on 2026-02-08
--  
SELECT
    ar.CUSTOMERCENTER,
    ar.CUSTOMERID,
    SUM(amount)
FROM
    FW.AR_TRANS art
JOIN FW.ACCOUNT_RECEIVABLES ar
ON
    ar.CENTER = art.CENTER
    AND ar.ID = art.ID
WHERE
    ar.AR_TYPE = 4
    AND art.ENTRY_TIME > :FromTime
    AND art.ENTRY_TIME < :ToTime
    AND art.EMPLOYEECENTER = 100
    AND art.EMPLOYEEID = 54333
GROUP BY
    ar.CUSTOMERCENTER,
    ar.CUSTOMERID