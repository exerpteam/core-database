-- The extract is extracted from Exerp on 2026-02-08
--  
SELECT
        p.center ||'p'|| p.id as memberid,
        p.fullname                              AS payer_name,
        prs.ref                            AS invoiceid,
        pr.REQ_AMOUNT,
        pr.REQ_DATE,
        pr.DUE_DATE,
   DECODE(pr.STATE,1,'New',2,'Sent',3,'Done',4,'Done, manual',5,'Rejected, clearinghouse',6,'Rejected, bank',7,'Rejected, debtor',8,'Cancelled',10,'Reversed, new',11,'Reversed, sent',12,'Failed, not creditor',13,'Reversed, rejected',14,'Reversed, confirmed',17,'Failed, payment revoked',18,'Done Partial',19,'Failed, Unsupported',20,'Require approval',21,'Fail, debt case exists',22,'Failed, timed out','Undefined') as "payment request state"
        
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

WHERE
   p.center in (:scope)
and
pr.REQ_DATE between :req_from_date and :req_to_date    
--and pr.state in (1,2,3,4,18)