SELECT DISTINCT
p.lastname name,
    ar.CUSTOMERCENTER || 'p' || ar.CUSTOMERID pid,
    art.DUE_DATE                              invoice_due_date,
    art.UNSETTLED_AMOUNT ,
    exerpro.longToDate(art.TRANS_TIME) invoice_TRANS_TIME,
    art.REF_TYPE ,
    art.TEXT                      text_account_transaction,
    inv.CENTER || 'inv' || inv.ID inv_id,
    invl.SUBID                    invoice_line_subid,
    invl.QUANTITY                 invoice_line_quantity,
    invl.TOTAL_AMOUNT             invoice_line_total_amount,
    prod.NAME                     product_name,
    spp.FROM_DATE                 sub_period_from,
    spp.TO_DATE                   sub_period_to,
    prs.REF                        payment_request_ref,
    pr.REQ_DATE                   payment_request_date,
    art.COLLECTED                 transaction_collected
FROM
    ACCOUNT_RECEIVABLES ar
join persons p on p.center = ar.customercenter and p.id = ar.customerid
JOIN
    AR_TRANS art
ON
    art.CENTER = ar.CENTER
    AND art.ID = ar.ID
    AND ar.AR_TYPE IN (:account_type)
LEFT JOIN
    PAYMENT_REQUEST_SPECIFICATIONS prs
ON
    prs.CENTER = art.PAYREQ_SPEC_CENTER
    AND prs.ID = art.PAYREQ_SPEC_ID
    AND prs.SUBID = art.PAYREQ_SPEC_SUBID
LEFT JOIN
    PAYMENT_REQUESTS pr
ON
    pr.INV_COLL_CENTER = prs.CENTER
    AND pr.INV_COLL_ID = prs.ID
    AND pr.INV_COLL_SUBID = prs.SUBID
LEFT JOIN
    INVOICES inv
ON
    inv.CENTER = art.REF_CENTER
    AND inv.id = art.REF_ID
    AND art.REF_TYPE = 'INVOICE'
LEFT JOIN
    INVOICELINES invl
ON
    invl.CENTER = inv.CENTER
    AND invl.ID = inv.ID
LEFT JOIN
    PRODUCTS prod
ON
    prod.CENTER = invl.PRODUCTCENTER
    AND prod.ID = invl.PRODUCTID
LEFT JOIN
    INVOICES inv2
ON
    inv2.SPONSOR_INVOICE_CENTER = inv.CENTER
    AND inv2.SPONSOR_INVOICE_ID = inv.ID
LEFT JOIN
    INVOICELINES invl2
ON
    invl2.SPONSOR_INVOICE_SUBID = invl.SUBID
    AND invl2.CENTER = inv2.CENTER
    AND invl2.ID = inv2.ID
LEFT JOIN
    SPP_INVOICELINES_LINK link
ON
    (
        invl2.CENTER IS NOT NULL
        AND link.INVOICELINE_CENTER = invl2.CENTER
        AND link.INVOICELINE_ID = invl2.ID
        AND link.INVOICELINE_SUBID = invl2.SUBID )
    OR (
        invl2.CENTER IS NULL
        AND link.INVOICELINE_CENTER = invl.CENTER
        AND link.INVOICELINE_ID = invl.ID
        AND link.INVOICELINE_SUBID = invl.SUBID )
LEFT JOIN
    SUBSCRIPTIONPERIODPARTS spp
ON
    spp.CENTER = link.PERIOD_CENTER
    AND spp.ID = link.PERIOD_ID
    AND spp.SUBID = link.PERIOD_SUBID
JOIN
    PERSONS p
ON
    p.CENTER = ar.CUSTOMERCENTER
    AND p.id = ar.CUSTOMERID
    AND p.SEX = 'C'
JOIN
    CENTERS c
ON
    c.ID = p.CENTER
    AND c.id IN ($$scope$$)
WHERE
	/*
    NOT EXISTS
    (
        SELECT
            *
        FROM
            CASHCOLLECTIONCASES cc
        WHERE
            cc.PERSONCENTER = p.CENTER
            AND cc.PERSONID = p.id
            AND cc.MISSINGPAYMENT = 1
            AND cc.CLOSED = 0)
    AND 
	*/
	art.DUE_DATE < exerpsysdate()
    AND art.UNSETTLED_AMOUNT < 0