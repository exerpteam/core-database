WITH
    params AS
    (
        SELECT
            DECODE($$offset$$,-1,0,(TRUNC(SYSDATE)-$$offset$$-to_date('1-1-1970 00:00:00','MM-DD-YYYY HH24:Mi:SS'))*24*3600*1000) AS FROMDATE,
            (TRUNC(SYSDATE+1)-to_date('1-1-1970 00:00:00','MM-DD-YYYY HH24:Mi:SS'))*24*3600*1000                                 AS TODATE
        FROM
            dual
    )
SELECT
    biview.*
FROM
    params,
(  SELECT
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
    TO_CHAR(longtodateC(i.ENTRY_TIME, i.CENTER), 'YYYY-MM-DD HH24:MI:SS') "ENTRY_DATE_TIME",
		case when i.TRANS_TIME < 253401762636000
    THEN TO_CHAR(longtodateC(i.TRANS_TIME, i.CENTER), 'YYYY-MM-DD HH24:MI:SS') 
	ELSE null
	END "BOOK_DATE_TIME",
    prod.CENTER                                                           "PRODUCT_CENTER",
    prod.CENTER || 'prod' || prod.ID                                      "PRODUCT_ID",
    BI_DECODE_FIELD('PRODUCTS','PTYPE',prod.PTYPE)  AS                     "PRODUCT_TYPE",
    il.PRODUCT_NORMAL_PRICE                         AS                     "PRODUCT_NORMAL_PRICE",
    il.QUANTITY                                     AS                     "QUANTITY",
    ROUND(il.net_amount,2)                          AS                     "NET_AMOUNT",
    ROUND(il.TOTAL_AMOUNT,2)-ROUND(il.net_amount,2) AS                     "VAT_AMOUNT",
    ROUND(il.TOTAL_AMOUNT, 2)                       AS                     "TOTAL_AMOUNT",
    CASE
        WHEN i.SPONSOR_INVOICE_CENTER IS NOT NULL
            AND il.SPONSOR_INVOICE_SUBID IS NULL
        THEN i.SPONSOR_INVOICE_CENTER || 'inv' || i.SPONSOR_INVOICE_ID || 'ln' || '1'
        WHEN i.SPONSOR_INVOICE_CENTER IS NOT NULL
        THEN i.SPONSOR_INVOICE_CENTER || 'inv' || i.SPONSOR_INVOICE_ID || 'ln' || il.SPONSOR_INVOICE_SUBID
        ELSE NULL
    END                    "SPONSOR_LINE_ID",
    debitacc.EXTERNAL_ID   "GL_DEBIT_ACCOUNT",
    credacc.EXTERNAL_ID    "GL_CREDIT_ACCOUNT",
    il.sales_commission                AS "SALES_COMMISSION",
    il.sales_units                     AS "SALES_UNITS",
    il.period_commission               AS "PERIOD_COMMISSION",
    COALESCE(crg.TYPE,'OTHER')         AS "SOURCE_TYPE",
    NULL                               AS "SALES_LOG_ID_CREDITED",
    il.center||'inv'||il.id            AS "SALE_ID",
    CAST ( crg.center AS VARCHAR(255)) AS "CASH_REGISTER_CENTER_ID",
    i.TRANS_TIME                          "TTS",
    i.ENTRY_TIME                          "ETS"
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
    TO_CHAR(longtodateC(c.ENTRY_TIME, c.CENTER), 'YYYY-MM-DD HH24:MI:SS') "ENTRY_DATE_TIME",
	case when c.TRANS_TIME < 253401762636000
    THEN TO_CHAR(longtodateC(c.TRANS_TIME, c.CENTER), 'YYYY-MM-DD HH24:MI:SS') 
	ELSE null
	END "BOOK_DATE_TIME",
    prod.CENTER                                                           "PRODUCT_CENTER",
    prod.CENTER || 'prod' || prod.ID                                      "PRODUCT_ID",
    BI_DECODE_FIELD('PRODUCTS','PTYPE',prod.PTYPE) AS                     "PRODUCT_TYPE",
    NULL ,
    - cl.QUANTITY                                    AS "QUANTITY",
    -ROUND(cl.net_amount,2)                          AS "NET_AMOUNT",
    -ROUND(cl.TOTAL_AMOUNT,2)+ROUND(cl.net_amount,2) AS "VAT_AMOUNT",
    -ROUND(cl.TOTAL_AMOUNT, 2)                       AS "TOTAL_AMOUNT",
    NULL,
    debitacc.EXTERNAL_ID   "GL_DEBIT_ACCOUNT",
    credacc.EXTERNAL_ID    "GL_CREDIT_ACCOUNT",
    cl.sales_commission                                                         AS "SALES_COMMISSION",
    cl.sales_units                                                              AS "SALES_UNITS",
    cl.period_commission                                                        AS "PERIOD_COMMISSION",
    COALESCE(crg.TYPE,'OTHER')                                                  AS "SOURCE_TYPE",
    cl.INVOICELINE_CENTER||'inv'||cl.INVOICELINE_ID||'ln'||cl.INVOICELINE_SUBID AS "SALES_LOG_ID_CREDITED",
    cl.CENTER || 'cred' || cl.ID                                                AS "SALE_ID",
    CAST ( crg.center AS VARCHAR(255))                                          AS "CASH_REGISTER_CENTER_ID",
    c.TRANS_TIME                                                                   "TST",
    c.ENTRY_TIME                                                                   "EST"
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

)
biview
WHERE
    biview.ETS BETWEEN PARAMS.FROMDATE AND PARAMS.TODATE