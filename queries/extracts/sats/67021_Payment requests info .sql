-- The extract is extracted from Exerp on 2026-02-08
--  
 SELECT
         TO_CHAR(CURRENT_DATE,'dd-mon-yyyy') AS extractdate,
         CASE
                 WHEN art.REF_TYPE = 'INVOICE' THEN spp.FROM_DATE
                 WHEN art.REF_TYPE = 'CREDIT_NOTE' THEN sppcn.FROM_DATE
                 ELSE NULL
         END AS "Invoiced Period From date",
         CASE
                 WHEN art.REF_TYPE = 'INVOICE' THEN spp.TO_DATE
                 WHEN art.REF_TYPE = 'CREDIT_NOTE' THEN sppcn.TO_DATE
                 ELSE NULL
         END AS "invoiced Period to date",
         CASE
                 WHEN art.REF_TYPE = 'INVOICE' THEN il.PERSON_CENTER ||'p'|| il.PERSON_ID
                 WHEN art.REF_TYPE = 'CREDIT_NOTE' THEN cl.PERSON_CENTER ||'p'|| cl.PERSON_ID
                 ELSE ''
         END AS "ID on person invoiced for",
         CASE
                 WHEN prel.CENTER IS NOT NULL THEN prel.fullname
                 WHEN prel2.CENTER IS NOT NULL THEN prel2.fullname
                 ELSE ''
         END AS "name on person invoiced for",
         CASE
                 WHEN prel.CENTER IS NOT NULL THEN prel.ssn
                 WHEN prel2.CENTER IS NOT NULL THEN prel2.ssn
                 ELSE ''
         END                                     AS "SSN on person invoiced for" ,
         ar.CUSTOMERCENTER ||'p'|| ar.CUSTOMERID AS payer_id,
         p.fullname                              AS payer_name,
         p.ssn,
         center.ORG_CODE,
         center.name,
         center.address1,
         center.zipcode ||' '|| center.city AS city,
         prs.ref                            AS invoiceid,
        CASE pr.state WHEN 1 THEN  'New' WHEN 2 THEN  'Sent' WHEN 3 THEN  'Done' WHEN 4 THEN  'Done, manual' WHEN 5 THEN  'Rejected, clearinghouse' WHEN 6 THEN 
                 'Rejected, bank' WHEN 7 THEN  'Rejected, debtor' WHEN 8 THEN  'Cancelled' WHEN 10 THEN  'Reversed, new' WHEN 11 THEN  'Reversed, sent'
                  WHEN 12 THEN  'Failed, not creditor' WHEN 13 THEN  'Reversed, rejected' WHEN 14 THEN  'Reversed, confirmed'  WHEN 17 THEN 
                 'Failed, payment revoked'  WHEN 18 THEN  'Done Partial'  WHEN 19 THEN  'Failed, Unsupported'  WHEN 20 THEN 
                 'Require approval'  WHEN 21 THEN 'Fail, debt case exists'  WHEN 22 THEN ' Failed, timed out' ELSE 'UNDEFINED' END AS state,
         pr.REQ_AMOUNT,
         (TOTAL_INVOICE_AMOUNT-REQUESTED_AMOUNT) AS "from previous invoices",
         pr.REQ_DATE,
         pr.DUE_DATE,
         CASE
                 WHEN art.REF_TYPE = 'INVOICE' THEN il.TEXT
                 WHEN art.REF_TYPE = 'CREDIT_NOTE' THEN cl.TEXT
                 ELSE art.text
         END AS "TEXT",
    CASE
             WHEN art.REF_TYPE = 'INVOICE' THEN il.TOTAL_AMOUNT
             WHEN art.REF_TYPE = 'CREDIT_NOTE' THEN -(cl.TOTAL_AMOUNT)
             WHEN art.REF_TYPE = 'ACCOUNT_TRANS' THEN art.AMOUNT
             ELSE 0
     END AS "TOTAL_AMOUNT", 
         CASE
                 WHEN art.REF_TYPE = 'INVOICE' THEN il.NET_AMOUNT
                 WHEN art.REF_TYPE = 'CREDIT_NOTE' THEN -(cl.NET_AMOUNT)
                 ELSE 0::int
         END AS "NET_AMOUNT",
         CASE
                 WHEN art.REF_TYPE = 'INVOICE' THEN (il.TOTAL_AMOUNT-il.NET_AMOUNT)
                 WHEN art.REF_TYPE = 'CREDIT_NOTE' THEN -(cl.TOTAL_AMOUNT-cl.NET_AMOUNT)
                 ELSE 0::int
         END AS "VAT amount",
         CASE
                 WHEN art.REF_TYPE = 'INVOICE' THEN (ilv.rate*100)
                 WHEN art.REF_TYPE = 'CREDIT_NOTE' THEN (clv.rate*100)
                 ELSE NULL
         END AS "VAT Rate",
         art.ref_type,
         art.text AS "TEXT consolidated"

 FROM
         PERSONS p
 JOIN
         PERSONS ap ON p.CENTER = ap.TRANSFERS_CURRENT_PRS_CENTER AND p.ID = ap.TRANSFERS_CURRENT_PRS_ID
 JOIN
         ACCOUNT_RECEIVABLES ar
         ON
                 ar.CUSTOMERCENTER = ap.CENTER
                 AND ar.CUSTOMERID = ap.ID
 JOIN
         PAYMENT_REQUEST_SPECIFICATIONS prs
         ON
                 prs.CENTER = ar.CENTER
                 AND prs.ID = ar.ID
 JOIN
         PAYMENT_REQUESTS pr
         ON
                 pr.INV_COLL_CENTER = prs.CENTER
                 AND pr.INV_COLL_ID = prs.ID
                 AND pr.INV_COLL_SUBID = prs.SUBID
 JOIN
         AR_TRANS art
         ON
                 prs.CENTER = art.PAYREQ_SPEC_CENTER
                 AND prs.ID = art.PAYREQ_SPEC_ID
                 AND prs.SUBID = art.PAYREQ_SPEC_SUBID
 JOIN
         CENTERS center
         ON
                 ap.CENTER = center.ID
 -- INVOICE
 LEFT JOIN
         INVOICES i
         ON
                 i.CENTER = art.REF_CENTER
                 AND i.ID = art.REF_ID
                 AND art.REF_TYPE = 'INVOICE'
 LEFT JOIN
         INVOICE_LINES_MT il
         ON
                 i.CENTER = il.CENTER
                 AND i.ID = il.ID
 LEFT JOIN
         INVOICELINES_VAT_AT_LINK ilv
         ON
                 il.CENTER = ilv.invoiceline_CENTER
                 AND il.id = ilv.invoiceline_id
                 AND il.subid = ilv.invoiceline_subid
 LEFT JOIN
         spp_invoicelines_link sppinvlnk
         ON
                 sppinvlnk.invoiceline_center = il.center
                 AND sppinvlnk.invoiceline_id = il.id
                 AND sppinvlnk.invoiceline_subid = il.subid
 LEFT JOIN
         subscriptionperiodparts spp
         ON
                 spp.center = sppinvlnk.period_center
                 AND spp.id = sppinvlnk.period_id
                 AND spp.subid = sppinvlnk.period_subid
 LEFT JOIN
         persons prel
         ON
                 il.PERSON_CENTER = prel.CENTER
                 AND il.PERSON_id = prel.ID
 -- CREDIT NOTES
 LEFT JOIN
         CREDIT_NOTES cn
         ON
                 cn.CENTER = art.REF_CENTER
                 AND cn.ID = art.REF_ID
                 AND art.REF_TYPE = 'CREDIT_NOTE'
 LEFT JOIN
         CREDIT_NOTE_LINES_MT cl
         ON
                 cn.CENTER = cl.CENTER
                 AND cn.ID = cl.ID
 LEFT JOIN
         CREDIT_NOTE_LINE_VAT_AT_LINK clv
         ON
                 cl.CENTER = clv.CREDIT_NOTE_LINE_CENTER
                 AND cl.id = clv.CREDIT_NOTE_LINE_ID
                 AND cl.subid = clv.CREDIT_NOTE_LINE_SUBID
 LEFT JOIN
         spp_invoicelines_link sppcnlnk
         ON
                 sppcnlnk.invoiceline_center = cl.center
                 AND sppcnlnk.invoiceline_id = cl.id
                 AND sppcnlnk.invoiceline_subid = cl.subid
 LEFT JOIN
         subscriptionperiodparts sppcn
         ON
                 sppcn.center = sppcnlnk.period_center
                 AND sppcn.id = sppcnlnk.period_id
                 AND sppcn.subid = sppcnlnk.period_subid
 LEFT JOIN
     Persons prel2
         ON
                cl.PERSON_CENTER = prel2.CENTER
                 AND cl.PERSON_ID = prel2.ID
 WHERE
       p.external_id in (:externalid)
 and
 pr.REQ_DATE between :from_date and :to_date
 AND art.COLLECTED IN (1,4,5)
 and pr.state in (3,4,18)
and art.text != 'API Sale Transaction'
