-- The extract is extracted from Exerp on 2026-02-08
--  
SELECT
ar.CUSTOMERCENTER ||'p'|| ar.CUSTOMERID as "memberid",
p.EXTERNAL_ID,
ar.BALANCE
FROM
ACCOUNT_RECEIVABLES ar
JOIN
persons p
ON
ar.customercenter = p.center
AND ar.customerid = p.id
WHERE
p.center in (:member)