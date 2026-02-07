WITH
    params AS
    (
        SELECT
            c.name                                            AS center,
            CAST(datetolongTZ(TO_CHAR(to_date($$From_Date$$,'YYYY-MM-DD'), 'YYYY-MM-DD' ),c.time_zone) AS BIGINT) AS fromdate,
            CAST(datetolongTZ(TO_CHAR(to_date($$To_Date$$,'YYYY-MM-DD'),  'YYYY-MM-DD' ),c.time_zone)+ (24*3600*1000) -1 AS BIGINT) AS todate,
            c.id                                                                 AS centerid
        FROM
            centers c
       WHERE
            c.id IN ($$Scope$$)
),
paymentMethods AS Materialized (
SELECT DISTINCT
    CAST((xpath('//attribute/@id',xml_element))[1] AS text)         AS "PAYMENT_METHOD_ID",
    CAST((xpath('//attribute/@name',xml_element))[1] AS text)            AS "NAME"
FROM
    (
        SELECT
            s.id,
            s.scope_type,
            s.scope_id,
            unnest(xpath('//attribute',xmlparse(document convert_from(s.mimevalue, 'UTF-8')) )) AS
            xml_element
        FROM
            systemproperties s
        WHERE
            s.globalid = 'PaymentMethodsConfig'
            and s.mimetype = 'text/xml') t
)    
SELECT
    params.center AS "Club",
    TO_CHAR(longtodateC(i.TRANS_TIME, i.center),'YYYY-MM-DD HH24:MI:SS')       AS  "Transaction Time",
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
    i.center||'inv'||i.id                    AS "Invoice No.",
    pm."NAME"                                AS "Payment Method Name",
    pe.txtvalue                             AS "Corporate Relation Text",
    cr.coment                               AS "Payment Text",    
    i.text                                   AS "Description",
    p.center || 'p' || p.id                  AS "Person ID",
    p.fullname                               AS "Person Name",
    pg.name                                  AS "Product Group",
    pr.name                                  AS "Product",
    ROUND(COALESCE(ill.rate,0) * 100,4) || '%' AS "Tax Rate",
    il.quantity                              AS "Sales Count",
    il.total_amount                          AS "Total Sales Amount",
    il.total_amount - il.net_amount          AS "Total Tax Amount",
    il.net_amount                            AS "Total Sales Excluding Tax",
    emp.Fullname                               AS "Sales Employee"
FROM
    INVOICES i
JOIN
    INVOICE_LINES_MT il
ON
    i.center = il.center
AND i.id = il.id
JOIN
    PARAMS
ON
    PARAMS.centerid = il.center  
JOIN
    CASHREGISTERTRANSACTIONS cr
ON
    cr.PAYSESSIONID = i.PAYSESSIONID    
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
LEFT JOIN
    PERSONS p
ON
    il.person_center = p.center
    AND il.person_id = p.id   
LEFT JOIN
    EMPLOYEES e
ON
    e.CENTER = cr.employeecenter
AND e.ID = cr.employeeid
LEFT JOIN
    PERSONS emp
ON
    emp.center = e.personcenter
AND emp.id = e.personid
LEFT JOIN
   paymentMethods pm
ON
   CAST (cr.config_payment_method_id AS VARCHAR(10)) = pm."PAYMENT_METHOD_ID"   
LEFT JOIN 
   person_ext_attrs pe
ON
   p.center = pe.personcenter 
   AND p.id = pe.personid 
   AND pe.name = 'companyrelation'   
WHERE
    i.trans_time BETWEEN params.fromdate AND params.todate
AND cr.config_payment_method_id IN (2, 5) -- Co-op & Send Invoice