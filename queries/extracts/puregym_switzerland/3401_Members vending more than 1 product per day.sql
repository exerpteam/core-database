-- The extract is extracted from Exerp on 2026-02-08
--  
SELECT
t1.count,
t1.center ||'p'|| t1.id AS member_id,
t1.fullname,
t1.trans_date,
t1.account_balance
FROM
(
SELECT
COUNT(*),
p.center,
p.id,
p.fullname,
ar.balance AS account_balance,
TO_CHAR(longtodateC(art.trans_time, art.center), 'YYYY-MM-DD') AS trans_date
FROM
persons p
JOIN
account_receivables ar
ON
ar.customercenter = p.center
AND ar.customerid = p.id
AND ar.ar_type = 1
JOIN
ar_trans art
ON
art.center = ar.center
AND art.id = ar.id
JOIN
invoices inv
ON
inv.center = art.ref_center
AND inv.id = art.ref_id
AND art.ref_type = 'INVOICE'
WHERE
inv.employee_center = 100
AND inv.employee_id = 2810
AND p.center IN (:scope)
GROUP BY
p.center,
p.id,
p.fullname,
trans_date,
account_balance
) t1
WHERE
t1.count > 1
ORDER BY
t1.trans_date,
t1.center,
t1.id