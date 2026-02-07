-- This is the version from 2026-02-05
--  
SELECT
    ar.CUSTOMERCENTER || 'p' || ar.CUSTOMERID AS pid,
    p.FIRSTNAME || ' ' || p.LASTNAME          AS full_name,
    art.AMOUNT refund_amount,
    pa.BANK_REGNO,
    pa.BANK_ACCNO
FROM
    FW.ACCOUNT_RECEIVABLES ar
JOIN FW.AR_TRANS art
ON
    art.CENTER = ar.CENTER
    AND art.ID = ar.ID
    AND ar.AR_TYPE = 4
JOIN FW.persons p
ON
    p.CENTER = ar.CUSTOMERCENTER
    AND p.id = ar.CUSTOMERID
    AND ar.AR_TYPE = 4

LEFT JOIN FW.PAYMENT_ACCOUNTS pac
ON
    pac.CENTER = ar.CENTER
    AND pac.ID = ar.ID
LEFT JOIN FW.PAYMENT_AGREEMENTS pa
ON
    pa.CENTER = pac.ACTIVE_AGR_CENTER
    AND pa.ID = pac.ACTIVE_AGR_ID
    AND pa.SUBID = pac.ACTIVE_AGR_SUBID
WHERE
    art.ENTRY_TIME >= 1286748000000
    AND art.EMPLOYEECENTER = 100
    AND art.EMPLOYEEID = 1
    and art.TEXT = 'retur til medlem'