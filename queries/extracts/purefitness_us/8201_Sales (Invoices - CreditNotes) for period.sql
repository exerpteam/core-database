WITH params AS
(
        SELECT
                dateToLongC(TO_CHAR(TO_DATE(:fromDate,'YYYY-MM-DD'),'YYYY-MM-DD'),c.id) fromDate,
                dateToLongC(TO_CHAR(TO_DATE(:toDate,'YYYY-MM-DD')+interval '1 days','YYYY-MM-DD'),c.id)-1 toDate,
                c.id,
                c.name
        FROM purefitnessus.centers c
        WHERE
                c.id IN (:Scope)
)
SELECT
        'Invoice' AS type,
        i.center || 'inv' || i.id AS transaction_id,
        par.name AS center_name,
        par.id AS center_id,
        p.center || 'p' || p.id AS person_id,
        p.external_id AS person_external_id,
        pay.center || 'p' || pay.id AS payer_id,
        pay.external_id AS payer_external_id,
        longtodatec(i.entry_time, i.center) AS entry_time,
        longtodatec(i.trans_time, i.center) AS book_time,
        il.net_amount,
        il.total_amount,
        il.quantity,
        pr.name AS product_name,
        pr.globalid AS product_global_id,
        (CASE pr.ptype
                 WHEN 1 THEN 'GOOD'
                 WHEN 2 THEN 'SERVICE'
                 WHEN 4 THEN 'CLIPCARD'
                 WHEN 5 THEN 'SUBSCRIPTION_NEW'
                 WHEN 10 THEN 'SUBSCRIPTION_PERIOD'
                 WHEN 12 THEN 'SUBSCRIPTION_PRO_RATA_PERIOD'
                 WHEN 6 THEN 'TRANSFER'
                 WHEN 7 THEN 'FREEZE_PERIOD'
                 WHEN 8 THEN 'GIFTCARD'
                 WHEN 9 THEN 'FREE_GIFTCARD'
                 WHEN 13 THEN 'SUBSCRIPTION_ADDON'
                 WHEN 14 THEN 'ACCESS'
                 ELSE 'Unknown'
        END) AS product_type,
        il.text AS line_text,
        i.text
FROM purefitnessus.invoices i
JOIN params par ON i.center = par.id
JOIN purefitnessus.invoice_lines_mt il ON i.center = il.center AND i.id = il.id
JOIN purefitnessus.persons p ON p.center = i.payer_center AND p.id = i.payer_id
JOIN purefitnessus.persons pay ON pay.center = il.person_center AND pay.id = il.person_id
LEFT JOIN purefitnessus.products pr ON il.productcenter = pr.center AND il.productid = pr.id
WHERE
        i.entry_time between par.fromDate AND par.toDate
        AND i.text NOT LIKE '%Converted subscription invoice%'
UNION ALL        
SELECT
        'CreditNote' AS type,
        cn.center || 'cred' || cn.id AS transaction_id,
        par.name AS center_name,
        par.id AS center_id,
        p.center || 'p' || p.id AS person_id,
        p.external_id AS person_external_id,
        pay.center || 'p' || pay.id AS payer_id,
        pay.external_id AS payer_external_id,
        longtodatec(cn.entry_time, cn.center) AS entry_time,
        longtodatec(cn.trans_time, cn.center) AS book_time,
        cnl.net_amount,
        cnl.total_amount,
        cnl.quantity,
        pr.name AS product_name,
        pr.globalid AS product_global_id,
        (CASE pr.ptype
                 WHEN 1 THEN 'GOOD'
                 WHEN 2 THEN 'SERVICE'
                 WHEN 4 THEN 'CLIPCARD'
                 WHEN 5 THEN 'SUBSCRIPTION_NEW'
                 WHEN 10 THEN 'SUBSCRIPTION_PERIOD'
                 WHEN 12 THEN 'SUBSCRIPTION_PRO_RATA_PERIOD'
                 WHEN 6 THEN 'TRANSFER'
                 WHEN 7 THEN 'FREEZE_PERIOD'
                 WHEN 8 THEN 'GIFTCARD'
                 WHEN 9 THEN 'FREE_GIFTCARD'
                 WHEN 13 THEN 'SUBSCRIPTION_ADDON'
                 WHEN 14 THEN 'ACCESS'
                 ELSE 'Unknown'
        END) AS product_type,
        cnl.text AS line_text,
        cn.text
FROM purefitnessus.credit_notes cn
JOIN params par ON cn.center = par.id
JOIN purefitnessus.credit_note_lines_mt cnl ON cn.center = cnl.center AND cn.id = cnl.id
JOIN purefitnessus.persons p ON p.center = cn.payer_center AND p.id = cn.payer_id
JOIN purefitnessus.persons pay ON pay.center = cnl.person_center AND pay.id = cnl.person_id
LEFT JOIN purefitnessus.products pr ON cnl.productcenter = pr.center AND cnl.productid = pr.id
WHERE
        cn.entry_time between par.fromDate AND par.toDate
        AND cn.text NOT LIKE '%Converted subscription invoice%';