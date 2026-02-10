-- The extract is extracted from Exerp on 2026-02-08
--  
 select
             p.center, p.id,
             p.FULLNAME as MEMBER_NAME,
             cli.id as REJECTION_FILE_ID,
             pr.req_AMOUNT as SENT_AMOUNT,
             art.AMOUNT as BOUNCED_AMOUNT,
             CASE pr.REQUEST_TYPE  WHEN 1 THEN  'PAYMENT'  WHEN 5 THEN  'REFUND'  WHEN 6 THEN  'REPRESENTATION'  WHEN 8 THEN  'ZERO'  ELSE 'UNKNOWN' END as type,
             to_char(pr.DUE_DATE, 'YYYY-MM-DD') COLLECTION_DATE,
             to_char(pr.XFR_DATE, 'YYYY-MM-DD') REJECTION_BANK_DATE,
             pr.XFR_INFO ARUDD_REASON_CODE,
             pag.BANK_ACCOUNT_HOLDER as ACCOUNT_HOLDER_NAME,
             pag.ref as BACS_REF,
             CASE pag.state WHEN 1 THEN 'Created' WHEN 2 THEN 'Sent' WHEN 3 THEN 'Failed' WHEN 4 THEN 'OK' WHEN 5 THEN 'Ended, bank' WHEN 6 THEN 'Ended, clearing house' WHEN 7 THEN 'Ended, debtor' WHEN 8 THEN 'Cancelled, not sent' WHEN 9 THEN 'Cancelled, sent' WHEN 10 THEN 'Ended, creditor' WHEN 11 THEN 'No agreement (deprecated)' WHEN 12 THEN 'Cash payment (deprecated)' WHEN 13 THEN 'Agreement not needed (invoice payment)' WHEN 14 THEN 'Agreement information incomplete' END as DDI_STATUS,
             to_char(cli.GENERATED_DATE, 'YYYY-MM-DD') as ADVICE_DATE
             --, art.*
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
 LEFT JOIN AR_TRANS art on art.CENTER = ar.center and art.id = ar.id --and art.INFO = pr.XFR_DELIVERY
 and art.PAYREQ_SPEC_CENTER = prs.center and art.PAYREQ_SPEC_ID = prs.id and art.PAYREQ_SPEC_SUBID = prs.subid and art.COLLECTED = 3
 and longtodateTZ(art.TRANS_TIME, 'Europe/London') = pr.XFR_DATE
 --JOIN AR_TRANS art on art.CENTER = ar.center and art.id = ar.id and art.COLLECTED = 3 and art.PAYREQ_SPEC_CENTER = prs.center and art.PAYREQ_SPEC_ID = prs.id and art.PAYREQ_SPEC_SUBID = prs.subid
 --and pr.XFR_DATE is not null and art.TRANS_TIME = datetolongTZ(to_char(pr.XFR_DATE, 'YYYY-MM-DD HH24:MI'), 'Europe/London');
 where pr.XFR_DATE >= :d and pr.XFR_DATE <= :d
 and (art.AMOUNT + pr.req_AMOUNT) != 0
