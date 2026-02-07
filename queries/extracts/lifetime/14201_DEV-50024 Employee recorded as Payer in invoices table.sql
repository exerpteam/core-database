SELECT DISTINCT
    i.center||'inv'||i.id                                                          AS invoice_id,
    TO_CHAR (longtodateTZ (i.trans_time, 'America/Toronto'), 'MM/DD/YYYY HH24:MI') AS "trans time",
    i.employee_center||'emp'||i.employee_id                                        AS employee,
    i.payer_center||'p'||i.payer_id                                                AS current_payer
    ,
    il.person_center||'p'||il.person_id AS new_payer,
    rchild.relativecenter IS NOT NULL   AS has_child,
    i.text,
    pr.name AS product_name,
    cc.recurring_participation_key
FROM
    invoices i
JOIN
    lifetime.invoice_lines_mt il
ON
    il.center = i.center
AND il.id = i.id
JOIN
    lifetime.products pr
ON
    pr.center = il.productcenter
AND pr.id = il.productid
LEFT JOIN
    lifetime.clipcards cc
ON
    cc.invoiceline_center = il.center
AND cc.invoiceline_id= il.id
AND cc.invoiceline_subid = il.subid
JOIN
    persons p
ON
    p.center = il.person_center
AND p.id = il.person_id
LEFT JOIN
    lifetime.relatives rchild
ON
    rchild.center = p.center
AND rchild.id = p.id
AND rchild.rtype = 14
WHERE
    i.payer_center = i.employee_center
AND i.payer_id = i.employee_id