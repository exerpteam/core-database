Select distinct
p.center ||'p'|| p.id as memberid,
pr.req_date,
pr.req_amount,
pr.xfr_info


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
where 
--p.center = 745 and p.id = 21609 and  
p.center in (:Scope)
and xfr_info = '803 - PaymentDetail not found'
and pr.req_date between :fromdate and :todate