-- The extract is extracted from Exerp on 2026-02-08
--  
WITH
     params AS
     (
         SELECT
             $$FromDate$$ AS FROMDATE,
             $$ToDate$$ + (1000*60*60*24) AS TODATE
     )
, credit_note_lines AS
(
SELECT 
    center,
    id,
    subid,
    invoiceline_center,
    invoiceline_id,
    invoiceline_subid,
    productcenter,
    productid,
    account_trans_center,
    account_trans_id,
    account_trans_subid,
    quantity,
    TEXT,
    credit_type,
    canceltype,
    total_amount,
    product_cost,
    reason,
    person_center,
    person_id,
    rebooking_acc_trans_center,
    rebooking_acc_trans_id,
    rebooking_acc_trans_subid,
    rebooking_to_center,
    installment_plan_id,
    sales_commission,
    sales_units,
    period_commission,
    net_amount,
    (   SELECT 
            l.account_trans_center
        FROM 
            credit_note_line_vat_at_link l
        WHERE 
            l.credit_note_line_center = line.center 
        AND l.credit_note_line_id = line.id 
        AND l.credit_note_line_subid = line.subid) AS vat_acc_trans_center,
    (   SELECT 
            l.account_trans_subid
        FROM 
            credit_note_line_vat_at_link l
        WHERE 
            l.credit_note_line_center = line.center 
        AND l.credit_note_line_id = line.id 
        AND l.credit_note_line_subid = line.subid) AS vat_acc_trans_subid,
    (   SELECT 
            l.account_trans_id
        FROM 
            credit_note_line_vat_at_link l
        WHERE 
            l.credit_note_line_center = line.center 
        AND l.credit_note_line_id = line.id 
        AND l.credit_note_line_subid = line.subid) AS vat_acc_trans_id,
    (   SELECT 
            l.rate
        FROM 
            credit_note_line_vat_at_link l
        WHERE 
            l.credit_note_line_center = line.center 
        AND l.credit_note_line_id = line.id 
        AND l.credit_note_line_subid = line.subid) AS rate,
    (   SELECT 
            l.orig_rate
        FROM 
            credit_note_line_vat_at_link l
        WHERE 
            l.credit_note_line_center = line.center 
        AND l.credit_note_line_id = line.id 
        AND l.credit_note_line_subid = line.subid) AS orig_rate
FROM 
    credit_note_lines_mt line
)
, invoicelines AS
(
SELECT 
    center,
    id,
    subid,
    productcenter,
    productid,
    account_trans_center,
    account_trans_id,
    account_trans_subid,
    quantity,
    TEXT,
    product_cost,
    product_normal_price,
    total_amount,
    sales_type,
    remove_from_inventory,
    reason,
    sponsor_invoice_subid,
    person_center,
    person_id,
    installment_plan_id,
    rebooking_acc_trans_center,
    rebooking_acc_trans_id,
    rebooking_acc_trans_subid,
    rebooking_to_center,
    sales_commission,
    sales_units,
    period_commission,
    net_amount,
    (   SELECT 
            l.account_trans_center
        FROM 
            invoicelines_vat_at_link l
        WHERE 
            l.invoiceline_center = line.center 
        AND l.invoiceline_id = line.id 
        AND l.invoiceline_subid = line.subid) AS vat_acc_trans_center,
    (   SELECT 
            l.account_trans_subid
        FROM 
            invoicelines_vat_at_link l
        WHERE 
            l.invoiceline_center = line.center 
        AND l.invoiceline_id = line.id 
        AND l.invoiceline_subid = line.subid) AS vat_acc_trans_subid,
    (   SELECT 
            l.account_trans_id
        FROM 
            invoicelines_vat_at_link l
        WHERE 
            l.invoiceline_center = line.center 
        AND l.invoiceline_id = line.id 
        AND l.invoiceline_subid = line.subid) AS vat_acc_trans_id,
    (   SELECT 
            l.rate
        FROM 
            invoicelines_vat_at_link l
        WHERE 
            l.invoiceline_center = line.center 
        AND l.invoiceline_id = line.id 
        AND l.invoiceline_subid = line.subid) AS rate,
    (   SELECT 
            l.orig_rate
        FROM 
            invoicelines_vat_at_link l
        WHERE 
            l.invoiceline_center = line.center 
        AND l.invoiceline_id = line.id 
        AND l.invoiceline_subid = line.subid) AS orig_rate
FROM 
    invoice_lines_mt line
)
, sales_vw AS
(
SELECT 
    il.center,
    il.id,
    il.subid        AS sub_id,
    'INVOICE'::TEXT AS sales_type,
    il.text,
    il.person_center,
    il.person_id,
    i.employee_center,
    i.employee_id,
    i.entry_time,
    i.trans_time,
    i.cashregister_center,
    i.cashregister_id,
    i.paysessionid,
    i.payer_center,
    i.payer_id,
    prod.center AS product_center,
    prod.id     AS product_id,
    prod.name   AS product_name,
    CASE prod.ptype
        WHEN 1 
        THEN 'RETAIL'::TEXT
        WHEN 2 
        THEN 'SERVICE'::TEXT
        WHEN 4 
        THEN 'CLIPCARD'::TEXT
        WHEN 5 
        THEN 'JOINING_FEE'::TEXT
        WHEN 6 
        THEN 'TRANSFER_FEE'::TEXT
        WHEN 7 
        THEN 'FREEZE_PERIOD'::TEXT
        WHEN 8 
        THEN 'GIFTCARD'::TEXT
        WHEN 9 
        THEN 'FREE_GIFTCARD'::TEXT
        WHEN 10 
        THEN 'SUBS_PERIOD'::TEXT
        WHEN 12 
        THEN 'SUBS_PRORATA'::TEXT
        WHEN 13 
        THEN 'ADDON'::TEXT
        WHEN 14 
        THEN 'ACCESS'::TEXT
        ELSE NULL::    TEXT
    END     AS product_type,
    pg.name AS product_group_name,
    il.quantity,
    ROUND(il.total_amount - il.total_amount * (1::NUMERIC - 1::NUMERIC / (1::NUMERIC + il.rate)), 
    2)                                                                             AS net_amount,
    ROUND(il.total_amount * (1::NUMERIC - 1::NUMERIC / (1::NUMERIC + il.rate)), 2) AS vat_amount,
    ROUND(il.total_amount, 2)                                                      AS total_amount 
    ,
    il.account_trans_center,
    il.account_trans_id,
    il.account_trans_subid,
    il.rebooking_acc_trans_center,
    il.rebooking_acc_trans_id,
    il.rebooking_acc_trans_subid,
    il.rebooking_to_center,
    i.sponsor_invoice_center,
    i.sponsor_invoice_id,
    il.sponsor_invoice_subid
FROM 
    invoicelines il
JOIN 
    invoices i 
ON 
    il.center = i.center 
AND il.id = i.id
JOIN 
    products prod 
ON 
    prod.center = il.productcenter 
AND prod.id = il.productid
LEFT JOIN 
    product_group pg 
ON 
    pg.id = prod.primary_product_group_id
 
UNION ALL
 
SELECT 
    cl.center,
    cl.id,
    cl.subid            AS sub_id,
    'CREDIT_NOTE'::TEXT AS sales_type,
    cl.text,
    cl.person_center,
    cl.person_id,
    c.employee_center,
    c.employee_id,
    c.entry_time,
    c.trans_time,
    c.cashregister_center,
    c.cashregister_id,
    c.paysessionid,
    c.payer_center,
    c.payer_id,
    prod.center AS product_center,
    prod.id     AS product_id,
    prod.name   AS product_name,
    CASE prod.ptype
        WHEN 1 
        THEN 'RETAIL'::TEXT
        WHEN 2 
        THEN 'SERVICE'::TEXT
        WHEN 4 
        THEN 'CLIPCARD'::TEXT
        WHEN 5 
        THEN 'JOINING_FEE'::TEXT
        WHEN 6 
        THEN 'TRANSFER_FEE'::TEXT
        WHEN 7 
        THEN 'FREEZE_PERIOD'::TEXT
        WHEN 8 
        THEN 'GIFTCARD'::TEXT
        WHEN 9 
        THEN 'FREE_GIFTCARD'::TEXT
        WHEN 10 
        THEN 'SUBS_PERIOD'::TEXT
        WHEN 12 
        THEN 'SUBS_PRORATA'::TEXT
        WHEN 13 
        THEN 'ADDON'::TEXT
        WHEN 14 
        THEN 'ACCESS'::TEXT
        ELSE NULL::    TEXT
    END           AS product_type,
    pg.name       AS product_group_name,
    - cl.quantity AS quantity,
    - ROUND(cl.total_amount - ROUND(cl.total_amount * (1::NUMERIC - 1::NUMERIC / (1::NUMERIC + 
    cl.rate)), 2), 2)                                                                AS net_amount,
    - ROUND(cl.total_amount * (1::NUMERIC - 1::NUMERIC / (1::NUMERIC + cl.rate)), 2) AS vat_amount 
    ,
    - ROUND(cl.total_amount, 2) AS total_amount,
    cl.account_trans_center,
    cl.account_trans_id,
    cl.account_trans_subid,
    cl.rebooking_acc_trans_center,
    cl.rebooking_acc_trans_id,
    cl.rebooking_acc_trans_subid,
    cl.rebooking_to_center,
    NULL::INTEGER AS sponsor_invoice_center,
    NULL::INTEGER AS sponsor_invoice_id,
    NULL::INTEGER AS sponsor_invoice_subid
FROM 
    credit_notes c
JOIN 
    credit_note_lines cl 
ON 
    cl.center = c.center 
AND cl.id = c.id
JOIN 
    products prod 
ON 
    prod.center = cl.productcenter 
AND prod.id = cl.productid
LEFT JOIN 
    product_group pg 
ON 
    pg.id = prod.primary_product_group_id
)
 SELECT
     sales.EMPLOYEE_CENTER || 'emp' || sales.EMPLOYEE_ID STAFF_ID,
     sales.PERSON_CENTER || 'p' || sales.PERSON_ID MEMBER_ID,
     pu.FULLNAME MEMBER_NAME,
     sales.PAYER_CENTER || 'p' || sales.PAYER_ID payer_id,
     pp.FULLNAME PAYER_NAME,
	 prod.NAME,
     TO_CHAR(longToDate(sales.TRANS_TIME), 'YYYY-MM-DD HH24:MI') transaction_time,
     sales.SALES_TYPE,
     cMember.SHORTNAME HOME_CENTRE,
     CASE
         WHEN cRebook.SHORTNAME IS NOT NULL
         THEN cRebook.SHORTNAME
         ELSE cSales.SHORTNAME
     END PT_CENTRE,
     prod.NAME,
     sales.PRODUCT_GROUP_NAME,
     sales.PRODUCT_TYPE,
     ROUND( SUM(sales.NET_AMOUNT), 2) revenue_excl_vat,
     ROUND( SUM(sales.TOTAL_AMOUNT), 2 ) vat_included,
     ROUND( SUM(sales.TOTAL_AMOUNT), 2 ) total_amount,
     SUM(sales.QUANTITY) quantity,
         pu.LAST_ACTIVE_START_DATE
 FROM
     SALES_VW sales
 CROSS JOIN
     PARAMS
 JOIN
     PRODUCTS prod
 ON
     prod.CENTER = sales.PRODUCT_CENTER
     AND prod.ID = sales.PRODUCT_ID
 JOIN
     CENTERS cMember
 ON
     cMember.ID = sales.PERSON_CENTER
 JOIN
     CENTERS cSales
 ON
     cSales.ID = sales.ACCOUNT_TRANS_CENTER
 JOIN
     ACCOUNT_TRANS act
 ON
     act.CENTER = sales.ACCOUNT_TRANS_CENTER
     AND act.ID = sales.ACCOUNT_TRANS_ID
     AND act.SUBID = sales.ACCOUNT_TRANS_SUBID
 JOIN
     ACCOUNTS debit
 ON
     debit.CENTER = act.DEBIT_ACCOUNTCENTER
     AND debit.ID = act.DEBIT_ACCOUNTID
 JOIN
     ACCOUNTS credit
 ON
     credit.CENTER = act.CREDIT_ACCOUNTCENTER
     AND credit.ID = act.CREDIT_ACCOUNTID
 LEFT JOIN
     CENTERS cRebook
 ON
     cRebook.ID = sales.REBOOKING_TO_CENTER
 LEFT JOIN
     PERSONS pp
 ON
     pp.CENTER = sales.PAYER_CENTER
     AND pp.id = sales.PAYER_ID
 LEFT JOIN
     PERSONS pu
 ON
     pu.CENTER = sales.PERSON_CENTER
     AND pu.id = sales.PERSON_ID
 WHERE
     sales.TRANS_TIME >= PARAMS.FROMDATE
     AND sales.TRANS_TIME < PARAMS.TODATE
     AND ( (
             sales.REBOOKING_TO_CENTER IS NULL
             AND sales.ACCOUNT_TRANS_CENTER IN ($$scope$$))
         OR (
             sales.REBOOKING_TO_CENTER IS NOT NULL
             AND sales.REBOOKING_TO_CENTER IN ($$scope$$)))
         AND (prod.NAME = 'In 2 Wellness')
 GROUP BY
 pu.LAST_ACTIVE_START_DATE,
     cMember.SHORTNAME ,
     cRebook.SHORTNAME,
     cSales.SHORTNAME ,
     prod.NAME ,
     pp.FULLNAME,
     pu.FULLNAME,
     sales.PRODUCT_TYPE,
     sales.PRODUCT_GROUP_NAME,
     sales.SALES_TYPE,
     sales.PAYER_CENTER || 'p' || sales.PAYER_ID ,
     sales.PERSON_CENTER || 'p' || sales.PERSON_ID ,
	 sales.EMPLOYEE_CENTER || 'emp' || sales.EMPLOYEE_ID,
     longToDate(sales.TRANS_TIME),
     debit.EXTERNAL_ID ,
     credit.EXTERNAL_ID
  ORDER BY 
	sales.EMPLOYEE_CENTER || 'emp' || sales.EMPLOYEE_ID asc