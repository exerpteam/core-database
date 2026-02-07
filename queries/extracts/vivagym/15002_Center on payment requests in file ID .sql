Select distinct

pr.center,
--pr.id,
pr.req_delivery as fileid

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

Where 
--p.center = 509 and p.id = 41880
pr.req_delivery = (:fileid)