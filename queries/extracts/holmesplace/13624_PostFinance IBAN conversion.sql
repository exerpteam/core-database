-- The extract is extracted from Exerp on 2026-02-08
--  

SELECT
    p.center || 'p' || p.id AS "PersonKey",
    ch.NAME                 AS "ClearingHouse",
    pa.REF                  AS "AgreementRef",
    pa.BANK_ACCNO           AS "BankAccount",
    pa.BANK_ACCOUNT_HOLDER  AS "AccountHolderName"
FROM
    PAYMENT_AGREEMENTS pa
JOIN
    PAYMENT_ACCOUNTS pac
ON
    pac.ACTIVE_AGR_CENTER = pa.center
AND pac.ACTIVE_AGR_ID = pa.id
AND pac.ACTIVE_AGR_SUBID = pa.SUBID
JOIN
    ACCOUNT_RECEIVABLES ar
ON
    ar.center = pac.center
AND ar.id = pac.id
JOIN
    PERSONS p
ON
    p.center = ar.CUSTOMERCENTER
AND p.id = ar.CUSTOMERID
JOIN
    CLEARINGHOUSES ch
ON
    ch.ID = pa.CLEARINGHOUSE
WHERE
    pa.CLEARINGHOUSE IN (3402,4811,4816,4607,4806)
AND pa.STATE IN (1,2,4)
AND pa.BANK_ACCNO IS NOT NULL