-- This is the version from 2026-02-05
--  
SELECT
    p.CENTER || 'p' || p.id pid,    
    s.CENTER || 'ss' || s.id ssid,
    ROUND(MONTHS_BETWEEN(exerpsysdate(),p.BIRTHDATE) / 12) age,
    prod.NAME sub_name,
    p.BIRTHDATE,
    ar.DEBIT_MAX
FROM
    ACCOUNT_RECEIVABLES ar
JOIN
    SUBSCRIPTIONS s
ON
    s.OWNER_CENTER = ar.CUSTOMERCENTER
    AND s.OWNER_ID = ar.CUSTOMERID
    AND s.CREATION_TIME > exerpro.dateToLong('2015-08-01 00:00')
join PRODUCTS prod on prod.CENTER = s.SUBSCRIPTIONTYPE_CENTER and prod.ID = s.SUBSCRIPTIONTYPE_ID    
JOIN
    PERSONS p
ON
    p.CENTER = s.OWNER_CENTER
    AND p.ID = s.OWNER_ID
    AND ROUND(MONTHS_BETWEEN(exerpsysdate(),p.BIRTHDATE) / 12) > 18
WHERE
    ar.DEBIT_MAX <= $$debit_max$$
    AND ar.AR_TYPE = 1
    AND NOT EXISTS
    (
        SELECT
            1
        FROM
            RELATIVES rel
        WHERE
            rel.RTYPE = 12
            AND rel.STATUS = 1
            AND rel.RELATIVECENTER = p.CENTER
            AND rel.RELATIVEID = p.id ) 