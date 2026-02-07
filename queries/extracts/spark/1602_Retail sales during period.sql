SELECT
t.center_name AS "Center",
t.product_name AS "Product Name",
--transaction_date AS "Date",
SUM(quantity) AS "Products sold"
FROM
(
SELECT
pr.name AS product_name,
--TO_CHAR(longtodateC(inv.trans_time, inv.center), 'YYYY-MM-DD') AS transaction_date,
invl.quantity,
c.name AS center_name
FROM
invoices inv
JOIN
invoice_lines_mt invl
ON
invl.center = inv.center
AND invl.id = inv.id
JOIN
products pr
ON
invl.productcenter = pr.center
AND invl.productid = pr.id
JOIN
centers c
ON
c.id = inv.center
WHERE
pr.ptype = 1
AND inv.center IN (:scope)
AND inv.trans_time BETWEEN :from_date AND :to_date
)t
GROUP BY
t.center_name,
t.product_name
ORDER BY
t.product_name,
t.center_name