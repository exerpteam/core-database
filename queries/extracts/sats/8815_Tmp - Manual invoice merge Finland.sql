SELECT
    p.CENTER || 'p' || p.id company_id,
    p.LASTNAME company_name,
    p.ADDRESS1,
    p.ADDRESS2,
    p.ZIPCODE,
    p.CITY,
    p.ssn company_id,
    prs.ref invoice_ref,
    prs.TOTAL_INVOICE_AMOUNT requstedAmount,
    TO_CHAR(longtodate(prs.ENTRY_TIME), 'DD.MM.YYYY') creation_date,
    TO_CHAR(prs.DUE_DATE, 'DD.MM.YYYY') due_date,
    TO_CHAR(longtodate(artSales.TRANS_TIME), 'DD.MM.YYYY') sales_date,
    artSales.TEXT,
    artSales.AMOUNT ar_amount,
    artSales.REF_TYPE,
    sales.excluding_vat,
    sales.included_vat,
    sales.total_amount
FROM
    PAYMENT_REQUEST_SPECIFICATIONS prs
JOIN ACCOUNT_RECEIVABLES ar
ON
    prs.center = ar.center
    AND prs.id = ar.id
JOIN PERSONS p
ON
    p.center = ar.CUSTOMERCENTER
    AND p.id = ar.CUSTOMERID
LEFT JOIN AR_TRANS artSales
ON
    artSales.PAYREQ_SPEC_CENTER = prs.center
    AND artSales.PAYREQ_SPEC_ID = prs.id
    AND artSales.PAYREQ_SPEC_SUBID = prs.subid
    AND artSales.REF_TYPE IN ('INVOICE', 'CREDIT_NOTE')
JOIN
    -- Invoices and credit notes with member id and sales club
    (
        SELECT
            i.center,
            i.id,
            prod.NAME pname,
            ROUND(SUM(il.TOTAL_AMOUNT - (il.TOTAL_AMOUNT * (1-(1/(1+il.RATE))))),2) excluding_vat,
            ROUND(SUM(il.TOTAL_AMOUNT * (1-(1/(1+il.RATE)))),2) included_vat,
            ROUND(SUM(il.TOTAL_AMOUNT), 2) total_amount,
            il.RATE vat_rate,
            ROUND((1-(1/(1+il.RATE))),7) included_vat_rate,
            'INVOICE' type
        FROM
            INVOICELINES il
        JOIN INVOICES i
        ON
            il.center = i.center
            AND il.id = i.id
        JOIN PRODUCTS prod
        ON
            prod.center = il.PRODUCTCENTER
            AND prod.id = il.PRODUCTID
        WHERE
            i.center BETWEEN 700 AND 800
            AND il.TOTAL_AMOUNT <> 0
            AND i.TRANS_TIME > datetolong('2010-06-01 00:00')
        GROUP BY
            i.center,
            i.id,
            prod.NAME,
            il.RATE
        UNION
        SELECT
            c.center,
            c.id,
            prod.NAME pname,
            -ROUND(SUM(cl.TOTAL_AMOUNT - ROUND(cl.TOTAL_AMOUNT * (1-(1/(1+cl.RATE))), 2)), 2) excluding_vat,
            -ROUND(SUM(cl.TOTAL_AMOUNT * (1-(1/(1+cl.RATE)))), 2) included_vat,
            -ROUND(SUM(cl.TOTAL_AMOUNT), 2) total_amount,
            cl.RATE vat_rate,
            ROUND((1-(1/(1+cl.RATE))),7) included_vat_rate,
            'CREDIT_NOTE' type
        FROM
            CREDIT_NOTE_LINES cl
        JOIN ECLUB2.CREDIT_NOTES c
        ON
            cl.center = c.center
            AND cl.id = c.id
        JOIN PRODUCTS prod
        ON
            prod.center = cl.PRODUCTCENTER
            AND prod.id = cl.PRODUCTID
        WHERE
            c.center BETWEEN 700 AND 800
            AND cl.TOTAL_AMOUNT <> 0
            AND c.TRANS_TIME > datetolong('2010-06-01 00:00')
        GROUP BY
            c.center,
            c.id,
            prod.NAME,
            longtodate(c.TRANS_TIME),
            cl.RATE
    )
    sales
ON
    -- Join the ar sales transactions to invoices and credit notes to find amount
    artSales.REF_CENTER = sales.center
    AND artSales.REF_ID = sales.id
    AND artSales.REF_TYPE = sales.TYPE
WHERE
    prs.CENTER BETWEEN 700 AND 800
    AND p.SEX = 'C'
    AND prs.INV_COMP_MIMEVALUE IS NOT NULL
    AND prs.ENTRY_TIME > datetolong('2010-07-14 23:59')
    AND prs.DUE_DATE >= TO_DATE('2010-08-14', 'yyyy-mm-dd')
    AND prs.DUE_DATE < TO_DATE('2010-08-15', 'yyyy-mm-dd')
ORDER BY
    7,8,12