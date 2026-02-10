-- The extract is extracted from Exerp on 2026-02-08
--  
SELECT
    pag.center,
    pag.id, 
    pag.subid,
    pag.creditor_id,
    i.payer_center||'p'||i.payer_id AS "PERSONKEY",
    il.total_amount,
    PR.NAME as "Product Name"
FROM
    ar_trans art
JOIN
    invoices i
ON
    art.ref_center = i.center
AND art.ref_id = i.id
AND art.ref_type = 'INVOICE'
JOIN
    account_receivables ar
ON
    ar.center = art.center
AND ar.id = art.id
AND ar.ar_type = 4
JOIN
    invoice_lines_mt il
ON
    i.center = il.center
AND i.id = il.id
JOIN
    products pr
ON
    il.productcenter = pr.center
AND il.productid = pr.id
JOIN 
    PAYMENT_AGREEMENTS pag
ON
    ar.center = pag.center
    AND ar.id = pag.id    
JOIN
    clearinghouses ch
ON
    ch.id = pag.clearinghouse        
WHERE
    pr.ptype = 4 
AND il.net_amount > 0
AND i.entry_time > CAST(datetolongC(TO_CHAR(CURRENT_DATE-:offset,'YYYY-MM-DD HH24:MI'),i.center) AS BIGINT)
AND pag.state = 4
AND pag.active
AND ch.ctype = 208 -- ACH
AND ar.balance < 0
AND pag.center in (:center)