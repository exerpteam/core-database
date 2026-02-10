-- The extract is extracted from Exerp on 2026-02-08
-- https://clublead.atlassian.net/browse/EC-3283
WITH
    params AS
    (
        SELECT
            c.name                                            AS center, 
            to_date(TO_CHAR(now(),'yyyy-mm-dd'),'yyyy-mm-dd') AS today, 
            CAST(datetolongTZ(TO_CHAR(to_date($$TransactionFromDate$$,'YYYY-MM-DD HH24:MI:SS'), 'YYYY-MM-DD HH24:MI:SS' ),c.time_zone) AS BIGINT) AS fromdate,
            CAST(datetolongTZ(TO_CHAR(to_date($$TransactionToDate$$,'YYYY-MM-DD HH24:MI:SS'),  'YYYY-MM-DD HH24:MI:SS' ),c.time_zone)+ (24*3600*1000) -1 AS BIGINT) AS todate,
            c.id                                                                 AS centerid
        FROM
            centers c
        WHERE
            c.id IN ($$Scope$$)
    )
SELECT
        params.center AS "Club",
        TO_CHAR(longtodateC(i.TRANS_TIME, i.center),'MM/DD/YYYY HH:MI:SS AM')       AS  "Transaction Time",
        CASE WHEN i.paysessionid IS NOT NULL THEN 'POS' ELSE 'WEB' END             AS  "Transaction Type",
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
        p.center || 'p' || p.id                  AS "Person ID",
        p.firstname                              AS "Person First Name",
        p.lastname                               AS "Person Last Name",
        pg.name                                  AS "Product Group",
        pr.name                                  AS "Product",
        pr.external_id                           AS "Product External ID",
        ROUND(COALESCE(ill.rate,0) * 100,4) || '%' AS "Tax Rate",
        il.quantity                              AS "Sales Count",
        il.total_amount                          AS "Total Sales Amount",
        il.total_amount - il.net_amount          AS "Total Tax Amount",
        sponsor.total_amount                     AS "Sponsored Sales Amount",
        il.net_amount                            AS "Total Sales Excluding Tax",
        emp.Fullname                               AS "Sales Employee",
        assigned.Fullname                        AS "Assigned Staff"
FROM invoices i
JOIN params
        ON params.centerid = i.center   
JOIN chelseapiers.invoice_lines_mt il
        ON i.center = il.center
        AND i.id = il.id
LEFT JOIN chelseapiers.products pr
        ON il.productcenter = pr.center
        AND il.productid = pr.id
LEFT JOIN persons p
        ON il.person_center = p.center
        AND il.person_id = p.id
/*LEFT JOIN chelseapiers.cashregistertransactions cr
        ON cr.paysessionid = i.paysessionid     */
LEFT JOIN product_group pg
        ON pg.id = pr.primary_product_group_id
LEFT JOIN invoicelines_vat_at_link ill
        ON ill.invoiceline_center = il.center
        AND ill.invoiceline_id = il.id
        AND ill.invoiceline_subid = il.subid
LEFT JOIN chelseapiers.employees e
        ON e.center = i.employee_center
        AND e.id = i.employee_id
LEFT JOIN persons emp
        ON emp.center = e.personcenter
        AND emp.id = e.personid
LEFT JOIN chelseapiers.invoice_lines_mt sponsor
        ON il.sponsor_invoice_subid = sponsor.subid
        AND i.center = sponsor.center
        AND i.id = sponsor.id
LEFT JOIN subscriptions s
        ON il.center = s.invoiceline_center
        AND il.id = s.invoiceline_id
        AND il.subid = s.invoiceline_subid
LEFT JOIN chelseapiers.persons assigned
        ON s.assigned_staff_center = assigned.center
        AND s.assigned_staff_id = assigned.id
WHERE
    i.trans_time BETWEEN params.fromdate AND params.todate
    AND ((i.paysessionid IS NOT NULL) 
    OR (i.employee_center = 100 AND i.employee_id = 2002))