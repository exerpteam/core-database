-- The extract is extracted from Exerp on 2026-02-08
--  
SELECT
    invl.text AS invl_text,
    --    invl.total_amount                       AS invl_total,
    --    invl.product_normal_price               AS product_normal_price,
    --    invl.product_cost                       AS product_cost,
    crt.amount                              AS requested_amount,
    crt2.amount                             AS change_amount,
    crt.customercenter||'p'||crt.customerid AS customer,
    TO_CHAR(longtodatec(crt.transtime,crt.center),'YYYY-MM-DD')   AS transactiontime,
    crt.crcenter||'cr'||crt.crid            AS cashregister_id,
    cr.name                                 AS cashregister_name
FROM
    goodlife.cashregistertransactions crt
JOIN
    goodlife.cashregistertransactions crt2
ON
    crt2.paysessionid = crt.paysessionid
    AND crt2.crttype =2
    AND crt.crttype = 7
LEFT JOIN
    goodlife.cashregistertransactions crt3
ON
    crt3.paysessionid = crt.paysessionid
    AND crt3.crttype = 1
LEFT JOIN
    goodlife.creditcardtransactions cct
ON
    crt.gltranscenter = cct.gl_trans_center
    AND crt.gltransid = cct.gl_trans_id
    AND crt.gltranssubid = cct.gl_trans_subid
JOIN
    goodlife.cashregisters cr
ON
    cr.center = crt.crcenter
    AND cr.id = crt.crid
LEFT JOIN
    goodlife.invoices inv
ON
    inv.paysessionid = crt.paysessionid
LEFT JOIN
    goodlife.invoice_lines_mt invl
ON
    invl.center = inv.center
    AND invl.id = inv.id
WHERE
    crt.amount > invl.total_amount
    AND invl.subid = 1
    AND crt3.center IS NULL