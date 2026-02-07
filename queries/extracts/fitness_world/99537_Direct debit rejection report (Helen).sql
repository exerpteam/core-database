-- This is the version from 2026-02-05
--  
SELECT
         p.center,
     p.id,
         cen.id as CLUB_ID,
     cen.NAME as "CENTER NAME",
     p.FULLNAME as "MEMBER NAME",
     pag.INDIVIDUAL_DEDUCTION_DAY as "NORMAL DD DAY",
     TO_CHAR(prs.ORIGINAL_DUE_DATE, 'YYYY-MM-DD')                                                     INIT_COLL_DATE,
     prs.REQUESTED_AMOUNT                                                                             INIT_AMOUNT,
     CASE pr.REQUEST_TYPE  WHEN 1 THEN  'PAYMENT'  WHEN 5 THEN  'REFUND'  WHEN 6 THEN  'REPRESENTATION'  WHEN 8 THEN  'ZERO'  ELSE 'UNKNOWN' END    AS type,
     TO_CHAR(pr.DUE_DATE, 'YYYY-MM-DD')                                                               COLLECTION_DATE,
     pr.REQ_AMOUNT                                                                                    SENT_AMOUNT,
     TO_CHAR(pr.XFR_DATE, 'YYYY-MM-DD')                                                               REJECTION_BANK_DATE,
     pr.XFR_INFO                                                                                      ARUDD_REASON_CODE,
     pag.BANK_ACCOUNT_HOLDER                                                                       AS ACCOUNT_HOLDER_NAME,
     CASE
             /* WHEN pr.FULL_REFERENCE IS NOT NULL
             THEN pr.FULL_REFERENCE*/
         WHEN LENGTH(pag.ref)>14
         THEN pag.ref
         ELSE rpad(pag.ref, 14, ' ') || pr.ref
     END                                                                                                                                                                                                        AS PR_BACS_REF,
     pag.ref                                                                                                                                                                                                        AS BACS_REF,
     CASE pag.state WHEN 1 THEN 'Created' WHEN 2 THEN 'Sent' WHEN 3 THEN 'Failed' WHEN 4 THEN 'OK' WHEN 5 THEN 'Ended, bank' WHEN 6 THEN 'Ended, clearing house' WHEN 7 THEN 'Ended, debtor' WHEN 8 THEN 'Cancelled, not sent' WHEN 9 THEN 'Cancelled, sent' WHEN 10 THEN 'Ended, creditor' WHEN 11 THEN 'No agreement (deprecated)' WHEN 12 THEN 'Cash payment (deprecated)' WHEN 13 THEN 'Agreement not needed (invoice payment)' WHEN 14 THEN 'Agreement information incomplete' END AS DDI_STATUS,
     cli.id                                                                                                                                                                                                        AS REJECTION_FILE_ID,
     TO_CHAR(cli.GENERATED_DATE, 'YYYY-MM-DD')                                                                                                                                                                                                        AS ADVICE_DATE
     --            ,art.amount
FROM
     PAYMENT_REQUESTS pr
JOIN
     PAYMENT_AGREEMENTS pag
ON
     pr.CENTER = pag.center
     AND pr.id = pag.id
     AND pr.AGR_SUBID = pag.subid
JOIN
     ACCOUNT_RECEIVABLES ar
ON
     ar.center = pag.center
     AND ar.id = pag.id
JOIN
     PERSONS p
ON
     p.center = ar.CUSTOMERCENTER
     AND p.id = ar.CUSTOMERID
JOIN
     PAYMENT_REQUEST_SPECIFICATIONS prs
ON
     prs.center = pr.INV_COLL_CENTER
     AND prs.id = pr.INV_COLL_ID
     AND prs.subid = pr.INV_COLL_SUBID
JOIN
     CLEARING_IN cli
ON
     cli.ID = pr.XFR_DELIVERY
     --JOIN AR_TRANS art on art.CENTER = ar.center and art.id = ar.id and art.COLLECTED = 3 and art.PAYREQ_SPEC_CENTER = prs.center and art.PAYREQ_SPEC_ID = prs.id and art.PAYREQ_SPEC_SUBID = prs.subid
     --and pr.XFR_DATE is not null and art.TRANS_TIME = datetolongTZ(to_char(pr.XFR_DATE, 'YYYY-MM-DD HH24:MI'), 'Europe/London');
JOIN CENTERS cen
on cen.ID = P.CENTER
WHERE
     pr.XFR_DATE >= :FromDate
     AND pr.XFR_DATE <= :ToDate
