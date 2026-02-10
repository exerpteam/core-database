-- The extract is extracted from Exerp on 2026-02-08
--  
SELECT DISTINCT
        p.center || 'p' || p.id AS "PersonID"
        ,c.name AS "Club"
        ,pr.clearinghouse_id AS "Clearing House ID"
        ,pr.req_date AS "Request Date"
        ,pr.req_amount AS "Amount"
        ,ch.name AS "Clearing House"
        ,pr.xfr_info AS "Rejection Info"
        ,pr.rejected_reason_code AS "Rejection Reason"
        ,CASE
                WHEN p.persontype = 0 THEN 'Private'
                WHEN p.persontype = 1 THEN 'Student'
                WHEN p.persontype = 2 THEN 'Staff'
                WHEN p.persontype = 3 THEN 'Friend'
                WHEN p.persontype = 4 THEN 'Corporate'
                WHEN p.persontype = 5 THEN 'Onemancorporate'
                WHEN p.persontype = 6 THEN 'Family'
                WHEN p.persontype = 7 THEN 'Senior'
                WHEN p.persontype = 8 THEN 'Guest'
                WHEN p.persontype = 9 THEN 'Child'
                WHEN p.persontype = 10 THEN 'External_Staff'
                ELSE 'Unknown'
        END AS "Person Type"
        ,CASE
                WHEN p.status = 0 THEN 'Lead'
                WHEN p.status = 1 THEN 'Active'
                WHEN p.status = 2 THEN 'Inactive'
                WHEN p.status = 3 THEN 'Temporary Inactive'
                WHEN p.status = 4 THEN 'Transfered'
                WHEN p.status = 5 THEN 'Duplicate'
                WHEN p.status = 6 THEN 'Prospect'
                WHEN p.status = 7 THEN 'Deleted'
                WHEN p.status = 8 THEN 'Anonymized'
                WHEN p.status = 9 THEN 'Contact'
                ELSE 'Unknown'
        END AS "Person Status" 
        ,ar.balance AS "Member Balance"
        ,CASE
                WHEN pag.state = 1 THEN 'Created'
                WHEN pag.state = 2 THEN 'Sent'
                WHEN pag.state = 3 THEN 'Failed'
                WHEN pag.state = 4 THEN 'OK'
                WHEN pag.state = 5 THEN 'Ended by bank'
                WHEN pag.state = 6 THEN 'Ended by clearing house'
                WHEN pag.state = 7 THEN 'Ended by debtor'
                WHEN pag.state = 8 THEN 'Cancelled, not sent'
                WHEN pag.state = 9 THEN 'Cancelled, sent'
                WHEN pag.state = 10 THEN 'Ended, creditor'
                WHEN pag.state = 11 THEN 'No agreement (deprecated)'
                WHEN pag.state = 12 THEN 'Cash payment (deprecated)'
                WHEN pag.state = 13 THEN 'Agreement not needed (invoice payment)'
                WHEN pag.state = 14 THEN 'Agreement information incomplete'
                WHEN pag.state = 15 THEN 'Transfer'
                WHEN pag.state = 16 THEN 'Agreement Recreated'
                WHEN pag.state = 17 THEN 'Signature missing'
                ELSE 'UNDEFINED'
         END AS "Payment Agreement State"
        ,CASE
                WHEN pag.state = 4 THEN NULL
                ELSE pag.ended_reason_text
        END AS "Payment Agreement Cancel Reason"  
        ,pr.full_reference 
        ,longtodatec(pr.entry_time,pr.center)
        ,CASE pr.STATE WHEN 1 THEN 'New' WHEN 2 THEN 'Sent' WHEN 3 THEN 'Done' WHEN 4 THEN 'Done, manual' WHEN 5 THEN 'Rejected, clearinghouse' WHEN 6 THEN 'Rejected, bank' WHEN 7 THEN 'Rejected, debtor' WHEN 8 THEN 'Cancelled' WHEN 10 THEN 'Reversed, new' WHEN 11 THEN 'Reversed , sent' WHEN 12 THEN 'Failed, not creditor' WHEN 13 THEN 'Reversed, rejected' WHEN 14 THEN 'Reversed, confirmed' WHEN 17 THEN 'Failed, payment revoked' WHEN 18 THEN 'Done Partial' WHEN 19 THEN 'Failed, Unsupported' WHEN 20 THEN 'Require approval' WHEN 21 THEN 'Fail, debt case exists' WHEN 22 THEN 'Failed, timed out' ELSE 'Undefined' END AS payment_request_state
        ,CASE REQUEST_TYPE WHEN 1 THEN 'Payment' WHEN 2 THEN 'Debt Collection' WHEN 3 THEN 'Reversal' WHEN 4 THEN 'Reminder' WHEN 5 THEN 'Refund' WHEN 6 THEN 'Representation' WHEN 7 THEN 'Legacy' WHEN 8 THEN 'Zero' WHEN 9 THEN 'Service Charge' ELSE 'Undefined' END AS REQUEST_TYPE         
        ,pr.creditor_id
        ,CASE pag.credit_card_type
                WHEN 1 THEN 'VISA'
                WHEN 2 THEN 'MasterCard'
                WHEN 5 THEN 'American Express'
        END AS Card_type   
FROM 
payment_agreements pag 
JOIN account_receivables ar ON ar.center = pag.center AND ar.id = pag.id
JOIN persons p ON p.center = ar.customercenter AND p.id = ar.customerid 
JOIN payment_requests pr ON pr.center = pag.center AND pr.id = pag.id AND pr.agr_subid = pag.subid
JOIN centers c ON c.id = pr.center
JOIN clearinghouses ch ON ch.id = pr.clearinghouse_id
JOIN payment_request_specifications prs on prs.center = pr.center and prs.id = pr.id and prs.subid = prs.subid
WHERE 
         p.sex != 'C'
         AND
         pr.req_date = :requestdate
         AND
         pr.REQUEST_TYPE IN (:REQUEST_TYPE)