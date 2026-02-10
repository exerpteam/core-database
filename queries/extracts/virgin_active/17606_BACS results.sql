-- The extract is extracted from Exerp on 2026-02-08
-- Adding payer reference to existing report
 SELECT
     c.id club_id,
     c.NAME club_name,
     ar.CUSTOMERCENTER || 'p' || ar.CUSTOMERID PID,
     p.FIRSTNAME,
     p.LASTNAME,
         pa.ref as DDI_Ref,
     longToDateC(pr.ENTRY_TIME,pr.center) REQUEST_CREATION_DATE,
     pr.REQ_DATE TRANSACTION_DATE,
     pr.DUE_DATE,
     prs.ORIGINAL_DUE_DATE original_due_date,
     CASE pr.state WHEN 1 THEN  'New' WHEN 2 THEN  'Sent' WHEN 3 THEN  'Done' WHEN 4 THEN  'Done, manual' WHEN 5 THEN  'Rejected, clearinghouse' WHEN 6 THEN  'Rejected, bank' WHEN 7 THEN  'Rejected, debtor' WHEN 8 THEN  'Cancelled' WHEN 10 THEN  'Reversed, new' WHEN 11 THEN  'Reversed, sent' WHEN 12 THEN  'Failed, not creditor' WHEN 13 THEN  'Reversed, rejected' WHEN 14 THEN  'Reversed, confirmed' WHEN 17 THEN 'Revoked by debitor' WHEN 18 THEN 'Done partial' WHEN 19 THEN 'Fail unsupported' ELSE 'UNDEFINED' END AS request_state,
     ch.NAME REVENUE_STREAM,
     pr.REJECTED_REASON_CODE,
     co.SENT_DATE file_sent_date,
     pr.XFR_INFO rejection_code_info,
     CASE
         WHEN art.REF_TYPE = 'CREDIT_NOTE'
         THEN cnl.TOTAL_AMOUNT * -1
         WHEN art.REF_TYPE = 'INVOICE'
         THEN invl.TOTAL_AMOUNT
         WHEN art.REF_TYPE = 'ACCOUNT_TRANS'
         THEN art.AMOUNT
         ELSE NULL
     END AS line_amount,
     pr.REQ_AMOUNT payment_request_amount,
     art.REF_TYPE,
     CASE
         WHEN art.REF_TYPE = 'INVOICE'
         THEN invl.TEXT
         WHEN art.REF_TYPE = 'CREDIT_NOTE'
         THEN cnl.TEXT
         WHEN art.REF_TYPE = 'ACCOUNT_TRANS'
         THEN art.TEXT
         ELSE NULL
     END AS "Transaction text",
     pr.XFR_DATE last_updated
 FROM
     PAYMENT_REQUESTS pr
 JOIN PAYMENT_REQUEST_SPECIFICATIONS prs
 ON
     prs.CENTER = pr.INV_COLL_CENTER
     AND prs.ID = pr.INV_COLL_ID
     AND prs.SUBID = pr.INV_COLL_SUBID
 LEFT JOIN PAYMENT_REQUESTS pr2
 ON
     pr2.INV_COLL_CENTER = prs.CENTER
     AND pr2.INV_COLL_ID = prs.ID
     AND pr2.INV_COLL_SUBID = prs.SUBID
     AND pr2.REQUEST_TYPE != 6
 LEFT JOIN AR_TRANS art
 ON
     art.PAYREQ_SPEC_CENTER = prs.CENTER
     AND art.PAYREQ_SPEC_ID = prs.ID
     AND art.PAYREQ_SPEC_SUBID = prs.SUBID
 LEFT JOIN INVOICELINES invl
 ON
     invl.CENTER = art.REF_CENTER
     AND invl.ID = art.REF_ID
     AND art.REF_TYPE = 'INVOICE'
 LEFT JOIN CREDIT_NOTE_LINES cnl
 ON
     cnl.CENTER = art.REF_CENTER
     AND cnl.ID = art.REF_ID
     AND art.REF_TYPE = 'CREDIT_NOTE'
 JOIN ACCOUNT_RECEIVABLES ar
 ON
     ar.CENTER = prs.CENTER
     AND ar.ID = prs.ID
 JOIN CENTERS c
 ON
     c.ID = ar.CUSTOMERCENTER
 LEFT JOIN PAYMENT_ACCOUNTS pac
 ON
     pac.CENTER = ar.CENTER
     AND pac.ID = ar.ID
 LEFT JOIN PAYMENT_AGREEMENTS pa
 ON
     pa.CENTER = pac.ACTIVE_AGR_CENTER
     AND pa.ID = pac.ACTIVE_AGR_ID
     AND pa.SUBID = pac.ACTIVE_AGR_SUBID
 LEFT JOIN CLEARINGHOUSES ch
 ON
     ch.ID = pa.CLEARINGHOUSE
 JOIN PERSONS p
 ON
     p.CENTER = ar.CUSTOMERCENTER
     AND p.ID = ar.CUSTOMERID
 LEFT JOIN CLEARING_OUT co
 ON
     co.ID = pr.REQ_DELIVERY
 WHERE
     pr.STATE NOT IN (1)
     AND pr.CREDITOR_ID = 'BACS UK'
     AND pr.REQ_DATE BETWEEN :reqDateFrom AND :reqDateTo + 1
         AND pr.CENTER in ($$Scope$$)
         and pr.state not in ($$exclude$$)
     /*AND pr.REQ_DATE BETWEEN '2014-10-01' AND '2014-10-09'*/
