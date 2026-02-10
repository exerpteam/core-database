-- The extract is extracted from Exerp on 2026-02-08
--  
WITH 
payment_requests AS
(
        SELECT
                ar.customercenter
                ,ar.customerid
                ,pr.req_date AS request_date
                ,CASE pr.STATE WHEN 1 THEN 'New' WHEN 2 THEN 'Sent' WHEN 3 THEN 'Done' WHEN 4 THEN 'Done, manual' WHEN 5 THEN 'Rejected, clearinghouse' WHEN 6 THEN 'Rejected, bank' WHEN 7 THEN 'Rejected, debtor' WHEN 8 THEN 'Cancelled' WHEN 10 THEN 'Reversed, new' WHEN 11 THEN 'Reversed , sent' WHEN 12 THEN 'Failed, not creditor' WHEN 13 THEN 'Reversed, rejected' WHEN 14 THEN 'Reversed, confirmed' WHEN 17 THEN 'Failed, payment revoked' WHEN 18 THEN 'Done Partial' WHEN 19 THEN 'Failed, Unsupported' WHEN 20 THEN 'Require approval' WHEN 21 THEN 'Fail, debt case exists' WHEN 22 THEN 'Failed, timed out' ELSE 'Undefined' END AS payment_request_state
                ,CASE REQUEST_TYPE WHEN 1 THEN 'Payment' WHEN 2 THEN 'Debt Collection' WHEN 3 THEN 'Reversal' WHEN 4 THEN 'Reminder' WHEN 5 THEN 'Refund' WHEN 6 THEN 'Representation' WHEN 7 THEN 'Legacy' WHEN 8 THEN 'Zero' WHEN 9 THEN 'Service Charge' ELSE 'Undefined' END AS REQUEST_TYPE
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
	pr.REQUEST_TYPE = 1

),
Payment_agreement AS
(
        select 
                s.owner_center,
                s.owner_id,
                pa.creditor_id,
                pa.subid,
                CASE pa.individual_deduction_day
                        WHEN 1 THEN 'Monday'
                        WHEN 2 THEN 'Tuesday'
                        WHEN 3 THEN 'Wednesday'
                        WHEN 4 THEN 'Thursday'
                        WHEN 5 THEN 'Friday'
                        WHEN 6 THEN 'Saturday'
                        WHEN 7 THEN 'Sunday'
                END AS deduction_day
                ,CASE pa.credit_card_type
                        WHEN 1 THEN 'VISA'
                        WHEN 2 THEN 'MasterCard'
                        WHEN 5 THEN 'American Express'
                END AS Card_type                        
        from subscriptions s 
        join payment_agreements pa 
                ON pa.center = s.payment_agreement_center 
                AND pa.id = s.payment_agreement_id 
                AND pa.subid = s.payment_agreement_subid
)
SELECT
        pr.customercenter||'p'||pr.customerid as Person_id,
        pr.request_date,
        pa.creditor_id,
        pa.subid,
        pa.deduction_day,
        pa.card_type      
FROM
        payment_requests pr
LEFT JOIN
        Payment_agreement pa
        ON pa.owner_center = pr.customercenter
        AND pa.owner_id = pr.customerid
WHERE
        pr.request_date = :date
AND
        pa.deduction_day = :deduction_day   
                                 



