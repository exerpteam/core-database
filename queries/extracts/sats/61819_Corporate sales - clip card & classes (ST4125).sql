WITH
    params AS
    (
        SELECT
            /*+ materialize */
            c.id,
            datetolongC(TO_CHAR($$from_date$$,'yyyy-MM-dd hh24:mi'),c.id) AS from_date,
            datetolongC(TO_CHAR($$to_date$$,'yyyy-MM-dd hh24:mi'),c.id) + 24*3600*1000 AS to_date
        FROM
            centers c
    )
SELECT
    DISTINCT 
    longtodateC(art.ENTRY_TIME, art.center) AS "Sales Date",
    c.NAME                                  AS "Center Name",
    c.id                                    AS "Center ID",
    csales_person.FULLNAME                  AS "Sales Person Name",
    staff.center||'emp'||staff.id           AS "Sales person ID",
    p.FULLNAME                              AS "Company name",
    p.center||'p'||p.id                     AS "Company ID",
    pr.NAME                                 AS "Product",
    il.QUANTITY                             AS "Quantity",
    il.TOTAL_AMOUNT                         AS "Sales Amount",
    DECODE(cnl.center,NULL,'','Credited')   AS "Is Credited",
    cnl.TOTAL_AMOUNT                        AS "Credited Amount"
FROM
    SATS.PRODUCT_GROUP pg
JOIN
    SATS.PRODUCT_AND_PRODUCT_GROUP_LINK pgl
ON
    pgl.PRODUCT_GROUP_ID = pg.ID
JOIN
    SATS.PRODUCTS pr
ON
    pgl.PRODUCT_CENTER = pr.CENTER
    AND pgl.PRODUCT_ID = pr.ID
JOIN
    SATS.INVOICE_LINES_MT il
ON
    il.PRODUCTCENTER = pr.CENTER
    AND il.PRODUCTID = pr.ID
JOIN
    params
ON
    params.id = il.center
JOIN
    SATS.INVOICES inv
ON
    inv.CENTER = il.CENTER
    AND inv.ID = il.ID
JOIN
    SATS.AR_TRANS art
ON
    inv.CENTER = art.REF_CENTER
    AND inv.ID = art.REF_ID
    AND art.REF_TYPE = 'INVOICE'
JOIN
    SATS.ACCOUNT_RECEIVABLES ar
ON
    ar.CENTER = art.CENTER
    AND ar.ID = art.ID
JOIN
    SATS.PERSONS p
ON
    p.CENTER = ar.CUSTOMERCENTER
    AND p.ID = ar.CUSTOMERID
JOIN
    centers c
ON
    c.id = il.center
LEFT JOIN
    EMPLOYEES staff
ON
    staff.center = inv.EMPLOYEE_CENTER
    AND staff.id = inv.EMPLOYEE_ID
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
    SATS.CREDIT_NOTE_LINES cnl
ON
    cnl.INVOICELINE_CENTER = il.center
    AND cnl.INVOICELINE_ID = il.id
    AND cnl.INVOICELINE_SUBID = il.SUBID
WHERE
    pg.NAME IN ('Föreläsningar + Tilläggspriser',
                'Klasser + Tilläggspriser',
                'Friskvårdspaket',
                'Friskvårdspaketen',
		'Rehab',
		'Corporate ST-4125')
    AND p.SEX = 'C'
    AND il.center IN ($$scope$$)
    AND art.ENTRY_TIME BETWEEN params.from_date AND params.to_date 