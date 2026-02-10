-- The extract is extracted from Exerp on 2026-02-08
-- Extract to help Tammy and Nathan until we get a the process finailized extract not tuned to multiple payment agreement.
SELECT
    p.firstname,
    p.lastname, 
    p.center || 'p' || p.id as PErsonID,
    par.individual_deduction_day
FROM
    PERSONS p
JOIN
    ACCOUNT_RECEIVABLES ar
ON
    ar.CUSTOMERCENTER = p.CENTER
    AND ar.CUSTOMERID = p.ID
    AND ar.AR_TYPE = 4
JOIN
    PAYMENT_ACCOUNTS pa
    on pa.CENTER = ar.CENTER and pa.id = ar.id
JOIN
    PAYMENT_AGREEMENTS par
ON
    pa.ACTIVE_AGR_CENTER = par.CENTER
    AND pa.ACTIVE_AGR_ID = par.ID
    AND pa.ACTIVE_AGR_SUBID = par.SUBID
    AND par.payment_cycle_config_id = 1
    where p.STATUS in (1,3) and p.CENTER in (:center)