-- The extract is extracted from Exerp on 2026-02-08
--  
SELECT
    il.CENTER || 'inv' || il.ID || 'ln' || il.SUBID "SALES_LINE_ID",
    il.CENTER                                       "CENTER_ID",
    'INVOICE'                                       "SALES_TYPE",
    CASE
        WHEN p.SEX <> 'C'
        THEN cp.EXTERNAL_ID
        ELSE NULL
    END "PERSON_ID",
    CASE
        WHEN cpayer.SEX = 'C'
        THEN cpayer.EXTERNAL_ID
        ELSE NULL
    END "COMPANY_ID",
    CASE
        WHEN cpayer.SEX = 'C'
        THEN 'TRUE'
        ELSE 'FALSE'
    END                                                                   "IS_COMPANY",
    csales_person.EXTERNAL_ID                                             "SALES_PERSON_ID",
    TO_CHAR(longtodateC(i.ENTRY_TIME, i.CENTER), 'YYYY-MM-DD HH24:MI:SS') "ENTRY_DATE_TIME" ,
    TO_CHAR(longtodateC(i.TRANS_TIME, i.CENTER), 'YYYY-MM-DD HH24:MI:SS') "BOOK_DATE_TIME",
    prod.CENTER                                                           "PRODUCT_CENTER",
    prod.CENTER || 'prod' || prod.ID                                      "PRODUCT_ID",
    BI_DECODE_FIELD('PRODUCTS','PTYPE',prod.PTYPE)  AS                     "PRODUCT_TYPE",
    REPLACE(REPLACE(REPLACE(TO_CHAR(il.PRODUCT_NORMAL_PRICE, 'FM999G999G999G999G990D00'), '.', '|'), ',', '.'),'|',',') AS "PRODUCT_NORMAL_PRICE",
    REPLACE(TO_CHAR(il.QUANTITY,'FM999G999G999G999G999'),',','.')   AS "QUANTITY",
    REPLACE(REPLACE(REPLACE(TO_CHAR(ROUND(il.net_amount,2), 'FM999G999G999G999G990D00'), '.', '|'), ',', '.'),'|',',') AS "NET_AMOUNT",
    REPLACE(REPLACE(REPLACE(TO_CHAR(ROUND(il.TOTAL_AMOUNT,2)-ROUND(il.net_amount,2), 'FM999G999G999G999G990D00'), '.', '|'), ',', '.'),'|',',') AS "VAT_AMOUNT",
    REPLACE(REPLACE(REPLACE(TO_CHAR(ROUND(il.TOTAL_AMOUNT, 2), 'FM999G999G999G999G990D00'), '.', '|'), ',', '.'),'|',',')  AS  "TOTAL_AMOUNT",
    CASE
        WHEN i.SPONSOR_INVOICE_CENTER IS NOT NULL
        AND il.SPONSOR_INVOICE_SUBID IS NULL
        THEN i.SPONSOR_INVOICE_CENTER || 'inv' || i.SPONSOR_INVOICE_ID || 'ln' || '1'
        WHEN i.SPONSOR_INVOICE_CENTER IS NOT NULL
        THEN i.SPONSOR_INVOICE_CENTER || 'inv' || i.SPONSOR_INVOICE_ID || 'ln' ||
            il.SPONSOR_INVOICE_SUBID
        ELSE NULL
    END                    "SPONSOR_LINE_ID",
    debitacc.EXTERNAL_ID   "GL_DEBIT_ACCOUNT",
    credacc.EXTERNAL_ID    "GL_CREDIT_ACCOUNT",
    REPLACE(TO_CHAR(il.sales_commission,'FM999G999G999G999G999'),',','.') AS "SALES_COMMISSION",
    REPLACE(TO_CHAR(il.sales_units,'FM999G999G999G999G999'),',','.') AS "SALES_UNITS",
    REPLACE(TO_CHAR(il.period_commission,'FM999G999G999G999G999'),',','.') AS "PERIOD_COMMISSION",
    COALESCE(crg.TYPE,'OTHER')         AS "SOURCE_TYPE",
    NULL                               AS "SALES_LOG_ID_CREDITED",
    il.center||'inv'||il.id            AS "SALE_ID",
    CAST ( crg.center AS VARCHAR(255)) AS "CASH_REGISTER_CENTER_ID",
    REPLACE(TO_CHAR(i.TRANS_TIME,'FM999G999G999G999G999'),',','.') AS "TTS",
    REPLACE(TO_CHAR(i.ENTRY_TIME,'FM999G999G999G999G999'),',','.') AS "ETS"
FROM
    invoice_lines_mt il
JOIN
    INVOICES i
ON
    il.center = i.center
AND il.id = i.id
JOIN
    PRODUCTS prod
ON
    prod.center = il.PRODUCTCENTER
AND prod.id = il.PRODUCTID
JOIN
    ACCOUNT_TRANS act
ON
    act.CENTER = il.ACCOUNT_TRANS_CENTER
AND act.ID = il.ACCOUNT_TRANS_ID
AND act.SUBID = il.ACCOUNT_TRANS_SUBID
JOIN
    ACCOUNTS credacc
ON
    act.CREDIT_ACCOUNTCENTER = credacc.CENTER
AND act.CREDIT_ACCOUNTID = credacc.ID
JOIN
    ACCOUNTS debitacc
ON
    act.DEBIT_ACCOUNTCENTER = debitacc.CENTER
AND act.DEBIT_ACCOUNTID = debitacc.ID
LEFT JOIN
    PRODUCT_GROUP pg
ON
    pg.ID = prod.PRIMARY_PRODUCT_GROUP_ID
LEFT JOIN
    PERSONS p
ON
    p.center = il.PERSON_CENTER
AND p.ID = il.PERSON_ID
LEFT JOIN
    PERSONS cp
ON
    cp.CENTER = p.CURRENT_PERSON_CENTER
AND cp.id = p.CURRENT_PERSON_ID
LEFT JOIN
    EMPLOYEES staff
ON
    staff.center = i.EMPLOYEE_CENTER
AND staff.id = i.EMPLOYEE_ID
LEFT JOIN
    PERSONS sales_person
ON
    sales_person.center = staff.personcenter
AND sales_person.ID = staff.personid
LEFT JOIN
    PERSONS csales_person
ON
    csales_person.center = sales_person.TRANSFERS_CURRENT_PRS_CENTER
AND csales_person.ID = sales_person.TRANSFERS_CURRENT_PRS_ID
LEFT JOIN
    CASHREGISTERS crg
ON
    crg.CENTER = i.CASHREGISTER_CENTER
AND crg.ID = i.CASHREGISTER_ID
LEFT JOIN
    PERSONS payer
ON
    payer.center = i.PAYER_CENTER
AND payer.id = i.PAYER_ID
LEFT JOIN
    PERSONS cpayer
ON
    cpayer.center = payer.TRANSFERS_CURRENT_PRS_CENTER
AND cpayer.ID = payer.TRANSFERS_CURRENT_PRS_ID
WHERE
    i.ENTRY_TIME BETWEEN (($$from_time$$-to_date('1-1-1970','DD-MM-YYYY')) )*24*3600*1000::bigint AND ((
            $$to_time$$-to_date('1-1-1970','DD-MM-YYYY')) )*24*3600*1000::bigint
UNION ALL
	
SELECT
    cl.CENTER || 'cred' || cl.ID || 'cnl' || cl.SUBID "SALES_LINE_ID",
    cl.CENTER                                         "CENTER_ID",
    'CREDIT_NOTE'                                     "SALES_TYPE",
    CASE
        WHEN p.SEX <> 'C'
        THEN p.EXTERNAL_ID
        ELSE NULL
    END "PERSON_ID",
    CASE
        WHEN cpayer.SEX = 'C'
        THEN cpayer.EXTERNAL_ID
        ELSE NULL
    END "COMPANY_ID",
    CASE
        WHEN cpayer.SEX = 'C'
        THEN 'TRUE'
        ELSE 'FALSE'
    END                                                                   "IS_COMPANY",
    csales_person.EXTERNAL_ID                                             "SALES_PERSON_ID",
    TO_CHAR(longtodateC(c.ENTRY_TIME, c.CENTER), 'YYYY-MM-DD HH24:MI:SS') "ENTRY_DATE_TIME" ,
    TO_CHAR(longtodateC(c.TRANS_TIME, c.CENTER), 'YYYY-MM-DD HH24:MI:SS') "BOOK_DATE_TIME",
    prod.CENTER                                                           "PRODUCT_CENTER",
    prod.CENTER || 'prod' || prod.ID                                      "PRODUCT_ID",
    BI_DECODE_FIELD('PRODUCTS','PTYPE',prod.PTYPE)   AS                     "PRODUCT_TYPE",
    NULL                                        AS                     "PRODUCT_NORMAL_PRICE",    
    REPLACE(TO_CHAR(-cl.QUANTITY,'FM999G999G999G999G999'),',','.')   AS "QUANTITY",
    REPLACE(REPLACE(REPLACE(TO_CHAR(-ROUND(cl.net_amount,2), 'FM999G999G999G999G990D00'), '.', '|'), ',', '.'),'|',',') AS "NET_AMOUNT",
    REPLACE(REPLACE(REPLACE(TO_CHAR(-ROUND(cl.TOTAL_AMOUNT,2)+ROUND(cl.net_amount,2), 'FM999G999G999G999G990D00'), '.', '|'), ',', '.'),'|',',') AS "VAT_AMOUNT",
    REPLACE(REPLACE(REPLACE(TO_CHAR(-ROUND(cl.TOTAL_AMOUNT, 2), 'FM999G999G999G999G990D00'), '.', '|'), ',', '.'),'|',',')  AS  "TOTAL_AMOUNT",
    NULL,
    debitacc.EXTERNAL_ID "GL_DEBIT_ACCOUNT",
    credacc.EXTERNAL_ID  "GL_CREDIT_ACCOUNT",
    REPLACE(TO_CHAR(cl.sales_commission,'FM999G999G999G999G999'),',','.') AS "SALES_COMMISSION",
    REPLACE(TO_CHAR(cl.sales_units,'FM999G999G999G999G999'),',','.') AS "SALES_UNITS",
    REPLACE(TO_CHAR(cl.period_commission,'FM999G999G999G999G999'),',','.') AS "PERIOD_COMMISSION",
    COALESCE(crg.TYPE,'OTHER')                                                  AS "SOURCE_TYPE",
    cl.INVOICELINE_CENTER||'inv'||cl.INVOICELINE_ID||'ln'||cl.INVOICELINE_SUBID AS
    "    SALES_LOG_ID_CREDITED",
    cl.CENTER || 'cred' || cl.ID       AS "SALE_ID",
    CAST ( crg.center AS VARCHAR(255)) AS "    CASH_REGISTER_CENTER_ID",
    REPLACE(TO_CHAR(c.TRANS_TIME,'FM999G999G999G999G999'),',','.') AS "TTS",
    REPLACE(TO_CHAR(c.ENTRY_TIME,'FM999G999G999G999G999'),',','.') AS "ETS"
FROM
    CREDIT_NOTES c
JOIN
    credit_note_lines_mt cl
ON
    cl.center = c.center
AND cl.id = c.id
JOIN
    PRODUCTS prod
ON
    prod.center = cl.PRODUCTCENTER
AND prod.id = cl.PRODUCTID
JOIN
    ACCOUNT_TRANS act
ON
    act.CENTER = cl.ACCOUNT_TRANS_CENTER
AND act.ID = cl.ACCOUNT_TRANS_ID
AND act.SUBID = cl.ACCOUNT_TRANS_SUBID
JOIN
    ACCOUNTS credacc
ON
    act.CREDIT_ACCOUNTCENTER = credacc.CENTER
AND act.CREDIT_ACCOUNTID = credacc.ID
JOIN
    ACCOUNTS debitacc
ON
    act.DEBIT_ACCOUNTCENTER = debitacc.CENTER
AND act.DEBIT_ACCOUNTID = debitacc.ID
LEFT JOIN
    PRODUCT_GROUP pg
ON
    pg.ID = prod.PRIMARY_PRODUCT_GROUP_ID
LEFT JOIN
    PERSONS p
ON
    p.center = cl.PERSON_CENTER
AND p.ID = cl.PERSON_ID
LEFT JOIN
    EMPLOYEES staff
ON
    staff.center = c.EMPLOYEE_CENTER
AND staff.id = c.EMPLOYEE_ID
LEFT JOIN
    PERSONS sales_person
ON
    sales_person.center = staff.personcenter
AND sales_person.ID = staff.personid
LEFT JOIN
    PERSONS csales_person
ON
    csales_person.center = sales_person.TRANSFERS_CURRENT_PRS_CENTER
AND csales_person.ID = sales_person.TRANSFERS_CURRENT_PRS_ID
LEFT JOIN
    CASHREGISTERS crg
ON
    crg.CENTER = c.CASHREGISTER_CENTER
AND crg.ID = c.CASHREGISTER_ID
LEFT JOIN
    PERSONS payer
ON
    payer.center = c.PAYER_CENTER
AND payer.id = c.PAYER_ID
LEFT JOIN
    PERSONS cpayer
ON
    cpayer.center = payer.TRANSFERS_CURRENT_PRS_CENTER
AND cpayer.ID = payer.TRANSFERS_CURRENT_PRS_ID
WHERE
    c.ENTRY_TIME BETWEEN (($$from_time$$-to_date('1-1-1970','DD-MM-YYYY')) )*24*3600*1000::bigint AND ((
            $$to_time$$-to_date('1-1-1970','DD-MM-YYYY')) )*24*3600*1000::bigint
	
