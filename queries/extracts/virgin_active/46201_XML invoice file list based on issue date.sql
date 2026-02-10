-- The extract is extracted from Exerp on 2026-02-08
--  
SELECT 
    distinct
    ar.CUSTOMERCENTER||'p'||ar.CUSTOMERID "Member ID",
    prs.REF,
    to_char(prs.ORIGINAL_DUE_DATE,'DD-MM-YYYY') AS "Due Date",
    to_char(longtodate(prs.ISSUED_DATE),'DD-MM-YYYY') AS "Issue Date",
    extract (day from (prs.ORIGINAL_DUE_DATE - longtodate(prs.ISSUED_DATE)) ) "Diff in days"
FROM
    PAYMENT_REQUEST_SPECIFICATIONS prs
JOIN
    CENTERS c
ON
   c.ID = prs.CENTER
   AND c.COUNTRY = 'IT'
JOIN 
    ACCOUNT_RECEIVABLES ar
ON 
   prs.CENTER = ar.CENTER
   AND prs.ID = ar.ID
   AND ar.ar_type = 4   
JOIN 
    AR_TRANS  art
ON
    art.PAYREQ_SPEC_CENTER = prs.CENTER
    AND art.PAYREQ_SPEC_ID = prs.ID
    AND art.PAYREQ_SPEC_SUBID = prs.SUBID
JOIN
    INVOICES i
ON
    i.CENTER = art.REF_CENTER
    AND i.ID = art.REF_ID  
JOIN
    INVOICE_LINES_MT il
ON 
    i.CENTER = il.CENTER
    AND i.ID = il.ID
WHERE 
   prs.REF is not null
   AND art.REF_TYPE = 'INVOICE' 
   AND prs.ISSUED_DATE >= :from_date
   AND prs.ISSUED_DATE < :to_date + 24*3600*1000
   