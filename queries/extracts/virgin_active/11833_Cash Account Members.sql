-- The extract is extracted from Exerp on 2026-02-08
--  
SELECT
    p.center                               AS "Center ID",
    c.NAME                                 AS "Center Name",
    AR.CUSTOMERCENTER ||'p'||ar.CUSTOMERID AS "Member ID",
    p.FULLNAME                             AS "Member Name",
    ar.DEBIT_MAX                           AS "Debit Max",
    ar.BALANCE                             AS "Account Balance"
FROM
    persons p
JOIN
    ACCOUNT_RECEIVABLES ar
ON
    p.center = ar.CUSTOMERCENTER
    AND p.id = ar.CUSTOMERID
JOIN
    centers c
ON
    p.CENTER = c.ID
WHERE
    AR_TYPE = 1
    AND AR.DEBIT_MAX > 0
    AND ar.STATE =0
    AND p.SEX != 'C'
    AND p.center IN (:scope)
ORDER BY
    p.center