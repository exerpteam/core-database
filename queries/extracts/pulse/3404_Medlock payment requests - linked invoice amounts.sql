SELECT
    p.CENTER || 'p' || p.id payerid,
    pr.REQ_AMOUNT,
    TO_CHAR(pr.REQ_DATE, 'YYYY-MM-DD') paymentDate,
    min(sales.pname),
    sum(sales.total_amount)
FROM
    PAYMENT_REQUESTS pr
JOIN PAYMENT_REQUEST_SPECIFICATIONS prs
ON
    pr.INV_COLL_CENTER = prs.CENTER
    AND pr.INV_COLL_ID = prs.ID
    AND pr.INV_COLL_SUBID = prs.SUBID
JOIN ACCOUNT_RECEIVABLES ar
ON
    pr.center = ar.center
    AND pr.id = ar.id
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
    AND artSales.TEXT not like ('New subscription sale%')
JOIN
    -- Invoices and credit notes with member id and sales club
    (
        SELECT
            i.center,
            i.id,
            i.PERSON_CENTER,
            i.PERSON_ID,
            prod.NAME pname,
            ROUND(SUM(il.TOTAL_AMOUNT - (il.TOTAL_AMOUNT * (1-(1/(1+il.RATE))))),2) excluding_vat,
            ROUND(SUM(il.TOTAL_AMOUNT * (1-(1/(1+il.RATE)))),2) included_vat,
            ROUND(SUM(il.TOTAL_AMOUNT), 2) total_amount,
            il.RATE vat_rate,
            ROUND((1-(1/(1+il.RATE))),7) included_vat_rate,
            'INVOICE' type
        FROM
            INVOICES i
        JOIN INVOICELINES il
        ON
            il.center = i.center
            AND il.id = i.id
        JOIN PRODUCTS prod
        ON
            prod.center = il.PRODUCTCENTER
            AND prod.id = il.PRODUCTID
        WHERE
            i.CENTER = 212
            AND il.TOTAL_AMOUNT <> 0
            AND prod.PTYPE in (10)
        GROUP BY
            i.center,
            i.id,
            i.PERSON_CENTER,
            i.PERSON_ID,
            prod.CENTER,
            prod.NAME,
            il.RATE
        UNION
        SELECT
            c.center,
            c.id,
            c.PERSON_CENTER,
            c.PERSON_ID,
            prod.NAME pname,
            -ROUND(SUM(cl.TOTAL_AMOUNT - ROUND(cl.TOTAL_AMOUNT * (1-(1/(1+cl.RATE))), 2)), 2) excluding_vat,
            -ROUND(SUM(cl.TOTAL_AMOUNT * (1-(1/(1+cl.RATE)))), 2) included_vat,
            -ROUND(SUM(cl.TOTAL_AMOUNT), 2) total_amount,
            cl.RATE vat_rate,
            ROUND((1-(1/(1+cl.RATE))),7) included_vat_rate,
            'CREDIT_NOTE' type
        FROM
            CREDIT_NOTES c
        JOIN CREDIT_NOTE_LINES cl
        ON
            cl.center = c.center
            AND cl.id = c.id
        JOIN ACTIC.PRODUCTS prod
        ON
            prod.center = cl.PRODUCTCENTER
            AND prod.id = cl.PRODUCTID
        WHERE
            c.CENTER = 212
            AND cl.TOTAL_AMOUNT <> 0
            AND prod.PTYPE in (10)
        GROUP BY
            c.center,
            c.id,
            c.PERSON_CENTER,
            c.PERSON_ID,
            prod.CENTER,
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
    pr.CENTER = 212
    AND pr.STATE in (3,4)
    AND pr.REQ_DATE >= :FromDate
    AND pr.REQ_DATE < :ToDate
group by
    p.CENTER || 'p' || p.id,
    pr.REQ_AMOUNT,
    TO_CHAR(pr.REQ_DATE, 'YYYY-MM-DD')
    --sales.pname
--having sum(sales.total_amount) <= req_amount
    