SELECT
    /*+ ORDERED  */
    clubs.COUNTRY,
    clubs.id salesClubId,
    clubs.SHORTNAME salesCenterShort,
    customer.center || 'p' || customer.id customerId,
    CASE
        WHEN customer.SEX = 'C'
        THEN 'Company'
        ELSE 'Member'
    END customerType,
    CASE
        WHEN customer.SEX = 'C'
        THEN customer.LASTNAME
        ELSE customer.FIRSTNAME || ' ' || customer.LASTNAME
    END customerName,
    sales.pname prodname,
    sales.prodType,
    TO_CHAR(longtodate(payments.salesTransTime), 'YYYY-MM-DD') salesDate,
    SUM(sales.excluding_vat) excl_vat,
    SUM(sales.included_vat) incl_vat,
    SUM(sales.total_amount) total,
    CASE
        WHEN payments.payerType = 'C'
        THEN 'Company'
        ELSE 'Member'
    END paidBy,
    payments.payerid payerId,
    payments.paymentDate
FROM
    (
        SELECT
            /*+ INDEX(act IDX_ACT_INFO_TIME, art IDX_AR_TRANS_REF, artSales IDX_PAYREQ_SPEC) */
            p.CENTER || 'p' || p.id payerid,
            prs.ref,
            TO_CHAR(longtodate(art.TRANS_TIME), 'YYYY-MM-DD') paymentDate,
            artSales.REF_CENTER,
            artSales.REF_ID,
            artSales.REF_TYPE,
            artSales.AMOUNT arAmount,
            artSales.TRANS_TIME salesTransTime,
            p.SEX payerType
        FROM
            ACCOUNT_TRANS act
        JOIN AR_TRANS art
        ON
            art.REF_TYPE = 'ACCOUNT_TRANS'
            AND art.REF_CENTER = act.center
            AND art.REF_ID = act.id
            AND art.REF_SUBID = act.subid
        JOIN ACCOUNT_RECEIVABLES ar
        ON
            art.center = ar.center
            AND art.id = ar.id
        JOIN PERSONS p
        ON
            p.center = ar.CUSTOMERCENTER
            AND p.id = ar.CUSTOMERID
        JOIN PAYMENT_REQUEST_SPECIFICATIONS prs
        ON
            prs.CENTER = art.CENTER
            AND prs.REF = art.INFO
            AND prs.REQUESTED_AMOUNT = art.AMOUNT
        JOIN AR_TRANS artSales
        ON
            artSales.PAYREQ_SPEC_CENTER = prs.center
            AND artSales.PAYREQ_SPEC_ID = prs.id
            AND artSales.PAYREQ_SPEC_SUBID = prs.subid
            AND artSales.REF_TYPE IN ('INVOICE', 'CREDIT_NOTE')
        WHERE
            act.INFO_TYPE IN (3, 4, 16)
            AND act.TRANS_TIME >= :FromDate
            AND act.TRANS_TIME < :ToDate + 1000*60*60*24
    )
    payments
JOIN
    -- Invoices and credit notes with member id and sales club
    (
        SELECT
            i.center,
            i.id,
            i.PAYER_CENTER,
            i.PAYER_ID,
            prod.NAME pname,
            CASE
                WHEN subT.ST_TYPE IS NULL
                THEN DECODE(prod.PTYPE, 1, 'Retail', 2, 'Service', 4, 'Clip card', 5, 'Joining Fee', 6, 'Transfer', 7,
                    'Freeze', 8, 'Gift card', 9, 'Free gift card', 10, 'Membership', 12, 'Membership', 'Unknown')
                WHEN subT.ST_TYPE = 0
                THEN 'Cash membership'
                ELSE 'EFT membership'
            END prodType,
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
        LEFT JOIN SUBSCRIPTIONTYPES subT
        ON
            subT.CENTER = prod.CENTER
            AND subT.ID = prod.ID
        WHERE
            i.ENTRY_TIME > :FromDate - 1000*60*60*24*180
            AND il.TOTAL_AMOUNT <> 0
        GROUP BY
            i.center,
            i.id,
            i.PAYER_CENTER,
            i.PAYER_ID,
            prod.CENTER,
            prod.NAME,
            prod.PTYPE,
            subT.ST_TYPE,
            il.RATE
        UNION ALL
        SELECT
            c.center,
            c.id,
            c.PAYER_CENTER,
            c.PAYER_ID,
            prod.NAME pname,
            CASE
                WHEN subT.ST_TYPE IS NULL
                THEN DECODE(prod.PTYPE, 1, 'Retail', 2, 'Service', 4, 'Clip card', 5, 'Joining Fee', 6, 'Transfer', 7,
                    'Freeze', 8, 'Gift card', 9, 'Free gift card', 10, 'Membership', 12, 'Membership', 'Unknown')
                WHEN subT.ST_TYPE = 0
                THEN 'Cash membership'
                ELSE 'EFT membership'
            END prodType,
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
        JOIN PRODUCTS prod
        ON
            prod.center = cl.PRODUCTCENTER
            AND prod.id = cl.PRODUCTID
        LEFT JOIN SUBSCRIPTIONTYPES subT
        ON
            subT.CENTER = prod.CENTER
            AND subT.ID = prod.ID
        WHERE
            c.ENTRY_TIME > :FromDate - 1000*60*60*24*180
            AND cl.TOTAL_AMOUNT <> 0
        GROUP BY
            c.center,
            c.id,
            c.PAYER_CENTER,
            c.PAYER_ID,
            prod.CENTER,
            prod.NAME,
            prod.PTYPE,
            subT.ST_TYPE,
            longtodate(c.TRANS_TIME),
            cl.RATE
    )
    sales
ON
    -- Join the ar sales transactions to invoices and credit notes to find amount
    payments.REF_CENTER = sales.center
    AND payments.REF_ID = sales.id
    AND payments.REF_TYPE = sales.TYPE
JOIN persons customer
ON
    -- Persons linked to invoices and credit notes - eg. the members paid for
    customer.CENTER = sales.payer_center
    AND customer.id = sales.payer_id
JOIN CENTERS clubs
ON
    -- Sales clubs from invoices and credit notes
    sales.center = clubs.id
WHERE
    customer.SEX = 'C'
    OR EXISTS
    (
        SELECT
            sl.center
        FROM
            STATE_CHANGE_LOG sl
        WHERE
            sl.CENTER = customer.CENTER
            AND sl.ID = customer.ID
            AND sl.ENTRY_TYPE = 3
            AND sl.STATEID = 4
            AND sl.ENTRY_START_TIME <= payments.salesTransTime
            AND
            (
                sl.ENTRY_END_TIME IS NULL
                OR sl.ENTRY_END_TIME > payments.salesTransTime
            )
    )
GROUP BY
    -- Grouping should ensure we get one amount per member per membership type per sales type
    clubs.COUNTRY,
    clubs.ID,
    clubs.NAME,
    clubs.SHORTNAME,
    customer.center || 'p' || customer.id,
    customer.FIRSTNAME,
    customer.LASTNAME,
    customer.SEX,
    sales.pname,
    sales.prodType,
    payments.salesTransTime,
    payments.payerType,
    payments.payerid,
    payments.paymentDate