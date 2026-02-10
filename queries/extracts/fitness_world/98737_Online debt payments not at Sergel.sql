-- The extract is extracted from Exerp on 2026-02-08
--  
SELECT
p.center ||'p'|| p.id AS memberid,
TO_CHAR(longtodate(art.entry_time), 'DD-MM-YYYY HH24:MI') AS transaction_time,
art.amount,
art.text
FROM
persons p
JOIN
account_receivables ar
ON
ar.customercenter = p.center
AND ar.customerid = p.id
AND ar.ar_type = 5
JOIN
ar_trans art
ON
art.center = ar.center
AND art.id = ar.id
AND (art.employeecenter,art.employeeid) = (114,40220)
AND art.trans_time BETWEEN :fromdate AND :todate
AND p.center IN (:scope)
ORDER BY
art.trans_time