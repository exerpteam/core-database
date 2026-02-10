-- The extract is extracted from Exerp on 2026-02-08
--  
SELECT
    p.center ||'p'|| p.id                                                   AS member_id,
    curr_per.external_id                                                    AS external_id,
    TO_CHAR(longtodateC(inv.trans_time, p.center), 'YYYY-MM-DD HH24:MI:SS') AS transaction_time,
    pr.name                                                                 AS product,
    invl.quantity                                                           AS quantity,
    invl.product_normal_price                                               AS normal_product_price
    ,
    invl.total_amount AS total_amount
FROM
    persons p
JOIN
    sats.invoice_lines_mt invl
ON
    invl.person_center = p.center
AND invl.person_id = p.id
JOIN
    products pr
ON
    pr.center = invl.productcenter
AND pr.id = invl.productid
JOIN
    invoices inv
ON
    inv.center = invl.center
AND inv.id = invl.id
JOIN
    persons curr_per
ON
    curr_per.center = p.current_person_center
AND curr_per.id = p.current_person_id
WHERE
    pr.ptype = 2
AND p.center IN (:scope)
AND inv.trans_time BETWEEN :from_date AND :to_date
AND pr.name IN (:product)