WITH
    params AS
    (
        SELECT
            c.name                                            AS center, 
            to_date(TO_CHAR(now(),'yyyy-mm-dd'),'yyyy-mm-dd') AS today, 
            CAST(datetolongTZ(TO_CHAR(to_date($$TransactionFromDate$$,'YYYY-MM-DD HH24:MI:SS'),
            'YYYY-MM-DD HH24:MI:SS' ),c.time_zone) AS BIGINT) AS fromdate,
            CAST(datetolongTZ(TO_CHAR(to_date($$TransactionToDate$$,'YYYY-MM-DD HH24:MI:SS'),
            'YYYY-MM-DD HH24:MI:SS' ),c.time_zone)+ (24*3600*1000) -1 AS BIGINT) AS todate,
            c.id                                                                 AS centerid
        FROM
            centers c
        WHERE
           c.id IN (:Scope)
    )
SELECT
il.reason,
    params.center AS "Club",
    il.person_center||'p'||il.person_id as "PersonID",
    CASE
        WHEN pr.PTYPE = 1
        THEN 'Goods'
        WHEN pr.PTYPE = 2
        THEN 'Service'
        WHEN pr.PTYPE = 4
        THEN 'Clipcard'
        WHEN pr.PTYPE = 5
        THEN 'Subscription creation'
        WHEN pr.PTYPE = 6
        THEN 'Transfer'
        WHEN pr.PTYPE = 7
        THEN 'Freeze period'
        WHEN pr.PTYPE = 8
        THEN 'Gift card'
        WHEN pr.PTYPE = 9
        THEN 'Free gift card'
        WHEN pr.PTYPE = 10
        THEN 'Subscription'
        WHEN pr.PTYPE = 12
        THEN 'Subscription pro-rata'
        WHEN pr.PTYPE = 13
        THEN 'Subscription add-on'
        WHEN pr.PTYPE = 14
        THEN 'Access product'
    END                                      AS "Product Type",
    pg.name                                  AS "Product Group",
    pr.name                                  AS "Product",
    pr.external_id                           AS "Product External ID",
    COALESCE(ill.rate,0) * 100 || '%' AS "Tax Rate",
    il.quantity                              AS "Sales Count",
    il.total_amount                          AS "Total Sales Amount",
    il.total_amount - il.net_amount          AS "Total Tax Amount",
    sponsor.total_amount                     AS "Sponsored Sales Amount",
    il.net_amount                            AS "Total Sales Excluding Tax",
    p.Fullname                               AS "Sales Employee",
    assigned.Fullname                        AS "Assigned Staff",
    i.cashregister_center as "Cash Register Center",
    i.cashregister_id as "Cash Register ID",
    att.*
from
    INVOICES i

JOIN
    INVOICE_LINES_MT il
ON
    i.center = il.center
AND i.id = il.id
JOIN
   PARAMS
ON
  params.centerid = il.center   
  left join account_trans att on att.center = il.account_trans_center and att.id = il.account_trans_id and att.subid = il.subid and att.trans_type = 4
LEFT JOIN
    PRODUCTS pr
ON
    il.productcenter = pr.center
AND il.productid = pr.id
LEFT JOIN
    product_group pg
ON
    pg.id = pr.primary_product_group_id
LEFT JOIN
    invoicelines_vat_at_link ill
ON
    ill.invoiceline_center = il.center
AND ill.invoiceline_id = il.id
AND ill.invoiceline_subid = il.subid
left join cashregistertransactions cr on cr.PAYSESSIONID = i.paysessionid
LEFT JOIN
    EMPLOYEES e
ON
    e.center = i.employee_center
AND e.id = i.employee_id
LEFT JOIN
    persons p
ON
    p.center = e.personcenter
AND p.id = e.personid
LEFT JOIN
    INVOICE_LINES_MT sponsor
ON
    il.sponsor_invoice_subid = sponsor.subid
AND i.center = sponsor.center
AND i.id = sponsor.id
LEFT JOIN
    subscriptions s
ON
    il.center = s.invoiceline_center
AND il.id = s.invoiceline_id
AND il.subid = s.invoiceline_subid
LEFT JOIN
    persons assigned
ON
    s.assigned_staff_center = assigned.CENTER
AND s.assigned_staff_id = assigned.ID
WHERE
    i.trans_time BETWEEN params.fromdate AND params.todate
   