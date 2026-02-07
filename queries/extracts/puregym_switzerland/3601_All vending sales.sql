SELECT
p.center ||'p'|| p.id AS member_id,
p.fullname,
pr.name AS product,
TO_CHAR(longtodateC(art.trans_time, art.center), 'YYYY-MM-DD HH24:MI:SS') AS trans_time,
invl.total_amount
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
JOIN
puregym_switzerland.invoice_lines_mt invl
ON
invl.center = inv.center
AND invl.id = inv.id
JOIN
products pr
ON
pr.center = invl.productcenter
AND pr.id = invl.productid
WHERE
inv.employee_center = 100
AND inv.employee_id = 2810
AND art.trans_time BETWEEN :from_date AND :to_date
AND p.center IN (:scope)
ORDER BY
art.trans_time,
p.center,
p.id