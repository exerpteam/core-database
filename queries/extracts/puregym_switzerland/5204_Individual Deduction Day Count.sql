-- The extract is extracted from Exerp on 2026-02-08
--  
SELECT
    case when par.INDIVIDUAL_DEDUCTION_DAY is Null
    then 'Total without individyúal deduction day defined'
    else par.INDIVIDUAL_DEDUCTION_DAY::varchar end  as "Individual deduction day",
    COUNT(*)
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
    where p.STATUS in (1,3) and p.CENTER in ($$scope$$)
GROUP BY
    grouping sets ( (par.INDIVIDUAL_DEDUCTION_DAY), ())