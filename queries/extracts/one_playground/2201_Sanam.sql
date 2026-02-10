-- The extract is extracted from Exerp on 2026-02-08
--  
SELECT
        ar.customercenter
        ,ar.customerid
        ,CAST(longtodatec(pr.entry_time,pr.center) AS date) as request_date
        ,pr.req_date
        ,pr.req_amount
        ,CASE pr.STATE WHEN 1 THEN 'New' WHEN 2 THEN 'Sent' WHEN 3 THEN 'Done' WHEN 4 THEN 'Done, manual' WHEN 5 THEN 'Rejected, clearinghouse' WHEN 6 THEN 'Rejected, bank' WHEN 7 THEN 'Rejected, debtor' WHEN 8 THEN 'Cancelled' WHEN 10 THEN 'Reversed, new' WHEN 11 THEN 'Reversed , sent' WHEN 12 THEN 'Failed, not creditor' WHEN 13 THEN 'Reversed, rejected' WHEN 14 THEN 'Reversed, confirmed' WHEN 17 THEN 'Failed, payment revoked' WHEN 18 THEN 'Done Partial' WHEN 19 THEN 'Failed, Unsupported' WHEN 20 THEN 'Require approval' WHEN 21 THEN 'Fail, debt case exists' WHEN 22 THEN 'Failed, timed out' ELSE 'Undefined' END AS payment_request_state
        ,CASE REQUEST_TYPE WHEN 1 THEN 'Payment' WHEN 2 THEN 'Debt Collection' WHEN 3 THEN 'Reversal' WHEN 4 THEN 'Reminder' WHEN 5 THEN 'Refund' WHEN 6 THEN 'Representation' WHEN 7 THEN 'Legacy' WHEN 8 THEN 'Zero' WHEN 9 THEN 'Service Charge' ELSE 'Undefined' END AS REQUEST_TYPE
        ,pr.creditor_id
        ,prs.paid_state
FROM 
        account_receivables ar
JOIN
        payment_requests pr
        ON ar.center = pr.center 
        AND ar.id = pr.id
JOIN
        payment_request_specifications prs
        ON pr.INV_COLL_CENTER = prs.CENTER
        AND pr.INV_COLL_ID = prs.ID
        AND pr.INV_COLL_SUBID = prs.SUBID 
WHERE   
        pr.req_date = :date      
                