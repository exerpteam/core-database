SELECT
    payerid,
    REQ_AMOUNT,
    paymentDate,
    MIN(sales.pname),
    ROUND(SUM(sales.TOTAL_AMOUNT), 2) total_amount
FROM
    (
        SELECT
            ar.CUSTOMERCENTER|| 'p' ||ar.CUSTOMERID payerid,
            pr.REQ_AMOUNT,
            TO_CHAR(pr.REQ_DATE, 'YYYY-MM-DD')    paymentDate,
            prod.name                          AS pname,
            il.TOTAL_AMOUNT
        FROM
            PAYMENT_REQUESTS pr
        JOIN
            PAYMENT_REQUEST_SPECIFICATIONS prs
        ON
            pr.INV_COLL_CENTER = prs.CENTER
        AND pr.INV_COLL_ID = prs.ID
        AND pr.INV_COLL_SUBID = prs.SUBID
        JOIN
            AR_TRANS artSales
        ON
            artSales.PAYREQ_SPEC_CENTER = prs.center
        AND artSales.PAYREQ_SPEC_ID = prs.id
        AND artSales.PAYREQ_SPEC_SUBID = prs.subid
        AND artSales.REF_TYPE IN ('INVOICE',
                                  'CREDIT_NOTE')
        AND artSales.TEXT NOT LIKE ('New subscription sale%')
        JOIN
            INVOICES i
        ON
            -- Join the ar sales transactions to invoices and credit notes to find amount
            artSales.REF_CENTER = i.center
        AND artSales.REF_ID = i.id
        AND artSales.REF_TYPE = 'INVOICE'
        JOIN
            INVOICELINES il
        ON
            il.center = i.center
        AND il.id = i.id
        AND il.TOTAL_AMOUNT <> 0
        JOIN
            PRODUCTS prod
        ON
            prod.center = il.PRODUCTCENTER
        AND prod.id = il.PRODUCTID
        AND prod.PTYPE IN (10)
        JOIN
            ACCOUNT_RECEIVABLES ar
        ON
            pr.center = ar.center
        AND pr.id = ar.id
        WHERE
            pr.CENTER = :club
        AND pr.STATE IN (1,2,3,4)
        AND pr.REQ_DATE >= :FromDate
        AND pr.REQ_DATE <= :ToDate
        UNION ALL
        SELECT
            ar.CUSTOMERCENTER|| 'p' ||ar.CUSTOMERID payerid,
            pr.REQ_AMOUNT,
            TO_CHAR(pr.REQ_DATE, 'YYYY-MM-DD') paymentDate,
            prod.name,
            -cl.TOTAL_AMOUNT
        FROM
            PAYMENT_REQUESTS pr
        JOIN
            PAYMENT_REQUEST_SPECIFICATIONS prs
        ON
            pr.INV_COLL_CENTER = prs.CENTER
        AND pr.INV_COLL_ID = prs.ID
        AND pr.INV_COLL_SUBID = prs.SUBID
        JOIN
            AR_TRANS artSales
        ON
            artSales.PAYREQ_SPEC_CENTER = prs.center
        AND artSales.PAYREQ_SPEC_ID = prs.id
        AND artSales.PAYREQ_SPEC_SUBID = prs.subid
        AND artSales.REF_TYPE IN ('INVOICE',
                                  'CREDIT_NOTE')
        AND artSales.TEXT NOT LIKE ('New subscription sale%')
        JOIN
            CREDIT_NOTES c
        ON
            -- Join the ar sales transactions to invoices and credit notes to find amount
            artSales.REF_CENTER = c.center
        AND artSales.REF_ID = c.id
        AND artSales.REF_TYPE = 'CREDIT_NOTE'
        JOIN
            CREDIT_NOTE_LINES cl
        ON
            cl.center = c.center
        AND cl.id = c.id
        AND cl.TOTAL_AMOUNT <> 0
        JOIN
            PRODUCTS prod
        ON
            prod.center = cl.PRODUCTCENTER
        AND prod.id = cl.PRODUCTID
        AND prod.PTYPE IN (10)
        JOIN
            ACCOUNT_RECEIVABLES ar
        ON
            pr.center = ar.center
        AND pr.id = ar.id
        WHERE
            pr.CENTER = :club
        AND pr.STATE IN (1,2,3,4)
        AND pr.REQ_DATE >= :FromDate
        AND pr.REQ_DATE <= :ToDate) sales
GROUP BY
    payerid,
    REQ_AMOUNT,
    paymentDate