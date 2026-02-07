SELECT distinct
         p.external_id as "shopper reference Adyen", 
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
         pr.DUE_DATE
     

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

 
 WHERE
  center.id in (:scope) and
 pr.REQ_DATE between :from_date and :to_date
 