SELECT
	center.SHORTNAME center,
    prs.ref InvoiceNo,
    prs.TOTAL_INVOICE_AMOUNT invoiceAmount,
  /*  TO_CHAR(prs.DUE_DATE, 'YYYY-MM-DD') DUEDATE,*/
    pr.REQ_DELIVERY requestFile,
    DECODE(pr.STATE, '1', 'New', '2', 'Sent', '3', 'Done', '4', 'Done manual', '5', 'Rejected, clearinghouse', '6',
    'Rejected, bank', '7', 'Rejected, debtor', '8', 'Cancelled', '18', 'Done partial', 'Unknown') state,
    ar.CUSTOMERCENTER || 'p' || ar.CUSTOMERID personid,
    per.FIRSTNAME,
    per.LASTNAME,
	pr.XFR_AMOUNT paymentAmount,
    TO_CHAR(pr.XFR_DATE, 'YYYY-MM-DD')  paymentDate,
    pr.XFR_DELIVERY paymentfile,
	pr.REQ_AMOUNT req_amount,
    TO_CHAR(pr.REQ_DATE, 'YYYY-MM-DD') DEDUCT_DATE,
    prs.CENTER || '-' || prs.ID || '-' || prs.SUBID payment_req_spec

, pr.full_reference 
FROM
    PAYMENT_REQUEST_SPECIFICATIONS prs
JOIN CENTERS center
ON
    center.id = prs.center
LEFT JOIN PAYMENT_REQUESTS pr
ON
    pr.INV_COLL_CENTER = prs.CENTER
    AND pr.INV_COLL_ID = prs.ID
    AND pr.INV_COLL_SUBID = prs.SUBID
LEFT JOIN ACCOUNT_RECEIVABLES ar
ON
    pr.center = ar.center
    AND pr.id = ar.id
LEFT JOIN PERSONS per
ON
    per.center = ar.CUSTOMERCENTER
    AND per.id = ar.CUSTOMERID
WHERE
	pr.center IN ( :scope ) 
	AND     (
        (
            '1' = :ClearingHouse
            AND pr.CLEARINGHOUSE_ID IN (1,202)
        )
        OR
        (
            '2' = :ClearingHouse
            AND pr.CLEARINGHOUSE_ID IN (2,201)
        )
or
   (
            '3' = :ClearingHouse
            AND pr.CLEARINGHOUSE_ID IN (402,803)
        )
    )
    AND longtodate(prs.ENTRY_TIME) >= :FromDate 
   AND longtodate(prs.ENTRY_TIME) < :ToDate + 1
ORDER BY
    prs.REF
  