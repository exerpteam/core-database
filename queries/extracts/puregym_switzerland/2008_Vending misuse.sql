-- The extract is extracted from Exerp on 2026-02-08
--  
SELECT
    p.center ||'p'|| p.id                                                   AS memberid,
    p.external_id                                                           AS external_id,
	p.fullname,
    ar.balance                                                              AS account_balance,
    TO_CHAR(longtodateC(inv.trans_time, p.center), 'DD-MM-YYYY HH24:MI:SS') AS transaction_time,
    inv.text                                                                AS transaction_text,
    pr.name                                                                 AS product_name,
    invl.total_amount                                                       AS product_price
FROM
    persons p
JOIN
    account_receivables ar
ON
    ar.customercenter = p.center
AND ar.customerid = p.id
AND ar.ar_type = 1
JOIN
    puregym_switzerland.ar_trans art
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
    puregym_switzerland.products pr
ON
    pr.center = invl.productcenter
AND pr.id = invl.productid
WHERE
    ar.balance < 0
AND art.status NOT IN ('CLOSED')
AND p.center IN (:scope)