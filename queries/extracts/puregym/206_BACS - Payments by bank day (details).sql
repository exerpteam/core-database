 select
             p.center, p.id,
             p.FULLNAME as MEMBER_NAME,
             CASE pr.REQUEST_TYPE  WHEN 1 THEN  'PAYMENT'  WHEN 5 THEN  'REFUND'  WHEN 6 THEN  'REPRESENTATION'  WHEN 8 THEN  'ZERO'  ELSE 'UNKNOWN' END AS type,
             CASE pr.STATE  WHEN '1' THEN  'New'  WHEN '2' THEN  'Sent'  WHEN '3' THEN  'Done'  WHEN '4' THEN  'Done maual'  WHEN '5' THEN  'Rejected, clearinghouse'
              WHEN '6' THEN  'Rejected, bank'  WHEN '7' THEN  'Rejected, debtor'  WHEN '8' THEN  'Cancelled'  WHEN '12' THEN 'Failed, no creditor'  WHEN '17' THEN 
             'Rejected, debtor'  WHEN '19' THEN  'Failed, not supported' END state,
             pag.INDIVIDUAL_DEDUCTION_DAY NORMAL_DD_DAY,
             TO_CHAR(prs.ORIGINAL_DUE_DATE, 'YYYY-MM-DD') INIT_COLL_DATE,
             prs.REQUESTED_AMOUNT INIT_AMOUNT,
             TO_CHAR(pr.DUE_DATE, 'YYYY-MM-DD') DEDUCTION_DATE,
             pr.REQ_AMOUNT SENT_AMOUNT,
             to_char(pr.DUE_DATE, 'YYYY-MM-DD') BANK_DATE,
             pr.XFR_INFO ARUDD_REASON_CODE,
             pag.BANK_ACCOUNT_HOLDER as ACCOUNT_HOLDER_NAME,
             pag.ref as BACS_REF,
             clo.id as SUBMISSION_FILE,
             clo.SENT_DATE as FILE_SENT_DATE
             --,art.amount
 FROM PAYMENT_REQUESTS pr
 JOIN PAYMENT_AGREEMENTS pag
         on pr.CENTER = pag.center and pr.id = pag.id and pr.AGR_SUBID = pag.subid
 JOIN ACCOUNT_RECEIVABLES ar on ar.center = pag.center and ar.id = pag.id
 JOIN PERSONS p
         ON p.center = ar.CUSTOMERCENTER AND p.id = ar.CUSTOMERID
 JOIN PAYMENT_REQUEST_SPECIFICATIONS prs on
             prs.center = pr.INV_COLL_CENTER
             AND prs.id = pr.INV_COLL_ID
             AND prs.subid = pr.INV_COLL_SUBID
 JOIN CLEARING_OUT clo on clo.ID = pr.REQ_DELIVERY
 --JOIN AR_TRANS art on art.CENTER = ar.center and art.id = ar.id and art.COLLECTED = 2 and art.PAYREQ_SPEC_CENTER = prs.center and art.PAYREQ_SPEC_ID = prs.id and art.PAYREQ_SPEC_SUBID = prs.subid
 --and art.TRANS_TIME = datetolongTZ(to_char(pr.DUE_DATE, 'YYYY-MM-DD HH24:MI'), 'Europe/London')
 where pr.DUE_DATE >= CAST(:FromDate AS DATE) and pr.DUE_DATE <= CAST(:ToDate AS DATE)
 and pr.CLEARINGHOUSE_ID = 1
