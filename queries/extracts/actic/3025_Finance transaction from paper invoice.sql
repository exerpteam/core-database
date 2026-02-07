SELECT
    sales.invId invoiceId,
    to_char(longtodate(sales.trans_time),'YYYY-MM-DD') bookdate,
    sales.AMOUNT,
    sales.vat,
    sales.aggTransId,
    p.CENTER || 'p' || p.id payerid,
    prs.ref,
    to_char(longtodate(prs.ENTRY_TIME),'YYYY-MM-DD') creationDate
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
    (
        SELECT
            i.center,
            i.id,
            i.center || 'inv' || i.id invId,
            i.TRANS_TIME,
            'INVOICE' type,
            act.AMOUNT,
            actVat.AMOUNT vat,
            act.AGGREGATED_TRANSACTION_CENTER || 'agt' || act.AGGREGATED_TRANSACTION_ID aggTransId,
            act.EXPORT_FILE
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
        LEFT JOIN ACCOUNT_TRANS act
        ON
            il.ACCOUNT_TRANS_CENTER = act.CENTER
            AND il.ACCOUNT_TRANS_ID = act.ID
            AND il.ACCOUNT_TRANS_SUBID = act.SUBID
        LEFT JOIN ACCOUNT_TRANS actVat
        ON
            il.VAT_ACC_TRANS_CENTER = actVat.CENTER
            AND il.VAT_ACC_TRANS_ID = actVat.ID
            AND il.VAT_ACC_TRANS_SUBID = actVat.SUBID
        UNION
        SELECT
            c.center,
            c.id,
            c.center || 'cred' || c.id invId,
            c.TRANS_TIME,
            'CREDIT_NOTE' type,
            -act.AMOUNT,
            -actVat.AMOUNT vat,
            act.AGGREGATED_TRANSACTION_CENTER || 'agt' || act.AGGREGATED_TRANSACTION_ID aggTransId,
            act.EXPORT_FILE
        FROM
            CREDIT_NOTES c
        LEFT JOIN CREDIT_NOTE_LINES cl
        ON
            cl.center = c.center
            AND cl.id = c.id
        JOIN PRODUCTS prod
        ON
            prod.center = cl.PRODUCTCENTER
            AND prod.id = cl.PRODUCTID
        LEFT JOIN ACCOUNT_TRANS act
        ON
            cl.ACCOUNT_TRANS_CENTER = act.CENTER
            AND cl.ACCOUNT_TRANS_ID = act.ID
            AND cl.ACCOUNT_TRANS_SUBID = act.SUBID
        LEFT JOIN ACCOUNT_TRANS actVat
        ON
            cl.VAT_ACC_TRANS_CENTER = actVat.CENTER
            AND cl.VAT_ACC_TRANS_ID = actVat.ID
            AND cl.VAT_ACC_TRANS_SUBID = actVat.SUBID
    )
    sales
ON
    artSales.REF_CENTER = sales.center
    AND artSales.REF_ID = sales.id
    AND artSales.REF_TYPE = sales.TYPE
WHERE
    prs.REF = :Reference
    AND artSales.REF_CENTER in (:Scope)
ORDER by sales.center, sales.trans_time