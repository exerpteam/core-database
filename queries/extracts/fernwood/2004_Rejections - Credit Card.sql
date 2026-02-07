WITH
        open_invoices AS
            (
                SELECT 
                        COUNT(*) As total
                        ,MIN(art.due_date) as MinDue
                        ,ar.center
                        ,ar.id
                FROM
                        fernwood.account_receivables ar
                JOIN
                        fernwood.ar_trans art   
                                ON art.center = ar.center    
                                AND art.id = ar.id        
                
                WHERE
                        ar.ar_type = 4
                        AND
                        art.status IN ('OPEN','NEW')
                        AND
                        art.due_date < current_date
                        AND
                        ar.balance < 0
                GROUP BY
                        ar.center
                        ,ar.id   
                ) 
SELECT 
        p.center || 'p' || p.id AS "PersonID"
        ,c.name AS "Club"
        ,p.firstname AS "First Name"
        ,p.lastname AS "Last Name"
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
        ,oi.total AS "Total Overdue Transactions"
        ,oi.MinDue AS "Oldest Debt" 
		     
FROM 
        fernwood.payment_agreements pag 
JOIN 
        fernwood.account_receivables ar 
                ON ar.center = pag.center 
                AND ar.id = pag.id
LEFT JOIN
        open_invoices oi
                ON oi.center = ar.center
                AND oi.id = ar.id                     
JOIN 
        fernwood.persons p 
                ON p.center = ar.customercenter 
                AND p.id = ar.customerid 
JOIN 
        fernwood.payment_requests pr 
                ON pr.center = pag.center 
                AND pr.id = pag.id 
                AND pr.agr_subid = pag.subid
JOIN 
        fernwood.centers c 
                ON c.id = pr.center
JOIN 
        fernwood.clearinghouses ch 
                ON ch.id = pr.clearinghouse_id
WHERE 
        pr.rejected_reason_code is not null
        AND
        longToDate(pr.entry_time) between :BillingStart and :BillingEnd
        AND 
        pr.clearinghouse_id  = 2
        AND 
        p.center in (:scope)