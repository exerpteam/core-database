 select
 collections.center,
 collections.BANK_DATE, 'CREDIT' as CreditDebit, '' || collections.SUBMISSION_FILE as SUBMIT_FILE_ID,
 sum(case when collections.type = 'PAYMENT' then collections.SENT_AMOUNT else 0 end) as NORMAL_01,
 sum(case when collections.type = 'REPRESENTATION' then collections.SENT_AMOUNT else 0 end) as REPRESENTATION_18,
 sum(case when collections.type = 'REFUND' then collections.SENT_AMOUNT else 0 end) as REFUND_TOTAL,
 sum(collections.SENT_AMOUNT) as TOTAL
 from
 (
 -- collections
 select
                         p.center,
             p.center || 'p' || p.id memberId,
             p.FULLNAME,
             CASE pr.REQUEST_TYPE  WHEN 1 THEN  'PAYMENT'  WHEN 5 THEN  'REFUND'  WHEN 6 THEN  'REPRESENTATION'  WHEN 8 THEN  'ZERO'  ELSE 'UNKNOWN' END as type,
             CASE pr.STATE  WHEN '1' THEN  'New'  WHEN '2' THEN  'Sent'  WHEN '3' THEN  'Done'  WHEN '4' THEN  'Done maual'  WHEN '5' THEN  'Rejected, clearinghouse'
              WHEN '6' THEN  'Rejected, bank'  WHEN '7' THEN  'Rejected, debtor'  WHEN '8' THEN  'Cancelled'  WHEN '12' THEN 'Failed, no creditor'  WHEN '17' THEN 
             'Rejected, debtor'  WHEN '19' THEN  'Failed, not supported' END state,
             prs.REQUESTED_AMOUNT INIT_AMOUNT,
             TO_CHAR(prs.ORIGINAL_DUE_DATE, 'YYYY-MM-DD') ORIG_DUE_DATE,
             pr.REQ_AMOUNT SENT_AMOUNT,
             pr.DUE_DATE DEDUCTION_DATE,
             to_char(pr.DUE_DATE, 'YYYY-MM-DD') BANK_DATE,
             pag.ref as COLLECTION_BACS_REF,
             pag.INDIVIDUAL_DEDUCTION_DAY NORMAL_DD_DAY,
             pr.XFR_INFO reasonCode,
             clo.id as SUBMISSION_FILE,
             clo.SENT_DATE
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
 where pr.DUE_DATE >= :FromDate and pr.DUE_DATE <= :ToDate
 and pr.CLEARINGHOUSE_ID = 1
 ) collections
 group by collections.BANK_DATE, collections.SUBMISSION_FILE, collections.center
 union all
 select bounces.CENTER,
 bounces.BANK_DATE, 'DEBIT' as CreditDebit, '' as SUBMIT_FILE_ID,
 sum(case when bounces.type = 'PAYMENT' then -bounces.SENT_AMOUNT else 0 end) as NORMAL_01,
 sum(case when bounces.type = 'REPRESENTATION' then -bounces.SENT_AMOUNT else 0 end) as REPRESENTATION_18,
 sum(case when bounces.type = 'REFUND' then bounces.SENT_AMOUNT else 0 end) as REFUND_TOTAL,
 sum(-bounces.SENT_AMOUNT) as TOTAL
 from
 (
 select
                         p.center,
             p.center || 'p' || p.id memberId,
             p.FULLNAME,
             CASE pr.REQUEST_TYPE  WHEN 1 THEN  'PAYMENT'  WHEN 5 THEN  'REFUND'  WHEN 6 THEN  'REPRESENTATION'  WHEN 8 THEN  'ZERO'  ELSE 'UNKNOWN' END as type,
             CASE pr.STATE  WHEN '1' THEN  'New'  WHEN '2' THEN  'Sent'  WHEN '3' THEN  'Done'  WHEN '4' THEN  'Done maual'  WHEN '5' THEN  'Rejected, clearinghouse'
              WHEN '6' THEN  'Rejected, bank'  WHEN '7' THEN  'Rejected, debtor'  WHEN '8' THEN  'Cancelled'  WHEN '12' THEN 'Failed, no creditor'  WHEN '17' THEN 
             'Rejected, debtor'  WHEN '19' THEN  'Failed, not supported' END state,
             prs.REQUESTED_AMOUNT INIT_AMOUNT,
             TO_CHAR(prs.ORIGINAL_DUE_DATE, 'YYYY-MM-DD') ORIG_DUE_DATE,
             pr.REQ_AMOUNT SENT_AMOUNT,
             pr.DUE_DATE DEDUCTION_DATE,
             pr.XFR_DATE REJECTED_DATE,
             to_char(pr.XFR_DATE, 'YYYY-MM-DD') BANK_DATE,
             pag.ref as CollectionBacsRef,
             pag.INDIVIDUAL_DEDUCTION_DAY NORMAL_DD_DAY,
             pr.XFR_INFO reasonCode
             ,cli.id as REJECTION_FILE
             ,cli.GENERATED_DATE
 --            ,art.amount
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
 JOIN CLEARING_IN cli on cli.ID = pr.XFR_DELIVERY
 --JOIN AR_TRANS art on art.CENTER = ar.center and art.id = ar.id and art.COLLECTED = 3 and art.PAYREQ_SPEC_CENTER = prs.center and art.PAYREQ_SPEC_ID = prs.id and art.PAYREQ_SPEC_SUBID = prs.subid
 --and pr.XFR_DATE is not null and art.TRANS_TIME = datetolongTZ(to_char(pr.XFR_DATE, 'YYYY-MM-DD HH24:MI'), 'Europe/London');
 where pr.XFR_DATE >= :FromDate and pr.XFR_DATE <= :ToDate
 and pr.CLEARINGHOUSE_ID = 1
 ) bounces
 group by bounces.BANK_DATE, bounces.center
 order by BANK_DATE, CENTER, CREDITDEBIT, SUBMIT_FILE_ID
