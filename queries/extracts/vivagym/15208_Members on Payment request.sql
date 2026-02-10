-- The extract is extracted from Exerp on 2026-02-08
--  
Select distinct
p.center ||'p'|| p.id as memberid,
pr.full_reference,
pr.req_amount,
prs.open_amount,
pr.req_date,
CASE pr.STATE WHEN 1 THEN 'New' WHEN 2 THEN 'Sent' WHEN 3 THEN 'Done' WHEN 4 THEN 'Done, manual' WHEN 5 THEN 'Rejected, clearinghouse' WHEN 6 THEN 'Rejected, bank' WHEN 7 THEN 'Rejected, debtor' WHEN 8 THEN 'Cancelled' WHEN 10 THEN 'Reversed, new' WHEN 11 THEN 'Reversed , sent' WHEN 12 THEN 'Failed, not creditor' WHEN 13 THEN 'Reversed, rejected' WHEN 14 THEN 'Reversed, confirmed' WHEN 17 THEN 'Failed, payment revoked' WHEN 18 THEN 'Done Partial' WHEN 19 THEN 'Failed, Unsupported' WHEN 20 THEN 'Require approval' WHEN 21 THEN 'Fail, debt case exists' WHEN 22 THEN 'Failed, timed out' ELSE 'Undefined' END AS payment_request_state

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
pr.full_reference in (:pr_reference)