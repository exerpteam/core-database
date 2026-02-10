-- The extract is extracted from Exerp on 2026-02-08
--  
SELECT
        DECODE(pr.STATE,1,'New',2,'Sent',3,'Done',4,'Done, manual',5,'Rejected, clearinghouse',6,'Rejected, bank',7,'Rejected, debtor',8,'Cancelled',10,'Reversed, new',11,'Reversed, sent',12,'Failed, not creditor',13,'Reversed, rejected',14,'Reversed, confirmed',17,'Failed, payment revoked',18,'Done Partial',19,'Failed, Unsupported',20,'Require approval',21,'Fail, debt case exists',22,'Failed, timed out','Undefined') as state
        ,ar.CUSTOMERCENTER || 'p' || ar.CUSTOMERID AS PersonId,
        pr.*
FROM
        FW.PAYMENT_REQUEST_SPECIFICATIONS prs
JOIN
        FW.ACCOUNT_RECEIVABLES ar ON prs.CENTER = ar.CENTER AND prs.ID = ar.ID
JOIN
        FW.PAYMENT_REQUESTS pr ON pr.INV_COLL_CENTER = prs.CENTER AND pr.INV_COLL_ID = prs.ID AND pr.INV_COLL_SUBID = prs.SUBID
WHERE
        pr.REQ_DATE = TO_DATE('2022-04-01','YYYY-MM-DD')
        AND pr.CLEARINGHOUSE_ID = 1212
        --AND pr.REJECTED_REASON_CODE = 'Error'
        --AND pr.STATE IN (State)
		AND pr.CENTER IN (:Scope)