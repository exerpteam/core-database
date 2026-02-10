-- The extract is extracted from Exerp on 2026-02-08
--  
SELECT DISTINCT
    p.center||'p'||p.id AS memberid,
    p.FULLNAME
FROM
    persons p
JOIN
    ACCOUNT_RECEIVABLES ar
ON
    ar.CUSTOMERCENTER = p.CENTER
AND ar.CUSTOMERID = p.id
JOIN
    PAYMENT_AGREEMENTS pa
ON
    pa.CENTER = ar.CENTER
AND pa.id = ar.id
AND pa.STATE in (1,2,4)
AND pa.ACTIVE = 1
JOIN
    PAYMENT_AGREEMENTS pa2
ON
    pa2.CENTER = ar.CENTER
AND pa2.id = ar.id
AND pa.SUBID != pa2.SUBID
AND pa2.STATE in (1,2,4)
AND pa2.ACTIVE = 1