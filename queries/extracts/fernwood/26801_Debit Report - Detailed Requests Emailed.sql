-- The extract is extracted from Exerp on 2026-02-08
--  
SELECT
        p.center || 'p' || p.id AS "ExerpId",
        p.fullname AS "Name",
        pag.ref AS "Reference",
        pag.clearinghouse_ref AS "Payway Customer Number", 		
        c.name as "Club",
        pr.req_amount AS "Amount including VAT (Exerp)",
        (CASE pr.state
                WHEN 1 THEN 'New'
                WHEN 2 THEN 'Sent'
                WHEN 3 THEN 'Done'
                WHEN 4 THEN 'Done manually'
                WHEN 5 THEN 'Failed, rejected by clearinghouse'
                WHEN 6 THEN 'Failed, bank rejected'
                WHEN 7 THEN 'Rejected, debtor'
                WHEN 8 THEN 'Cancelled'
                WHEN 12 THEN 'Failed, could not be sent'
                WHEN 17 THEN 'Failed, payment revoked'
                WHEN 19 THEN 'Failed, not supported'
                WHEN 20 THEN 'Requires approval'
                ELSE 'Unknown'
        END) AS "PR State",
        CASE
                WHEN pr.clearinghouse_id = 1 THEN 'Bank Account'
                WHEN pr.clearinghouse_id = 2 THEN 'Credit Card'
        END AS "ClearingHouseID",
        pr.req_date AS "Date",
        CASE
                WHEN pr.request_type = 1 THEN 'Payment'
                WHEN pr.request_type = 6 THEN 'Representation'
                WHEN pr.request_type = 5 THEN 'Refund'
        END AS "Request Type",  
        pr.center AS "Center",
        pr.req_delivery AS "File ID",    
        CASE
                WHEN pr.clearinghouse_id = 2 THEN TO_CHAR(longtodateC(pr.last_modified, pr.center), 'YYYY-MM-DD HH24:MI') 
                ELSE NULL
        END AS "Payment Request date and Time"                                                        
FROM 
        payment_agreements pag 
JOIN 
        account_receivables ar 
        ON ar.center = pag.center 
        AND ar.id = pag.id
JOIN 
        persons p 
        ON p.center = ar.customercenter 
        AND p.id = ar.customerid
JOIN 
        payment_requests pr 
        ON pr.center = pag.center 
        AND pr.id = pag.id 
        AND pr.agr_subid = pag.subid 
        AND pr.state <> 8
JOIN 
        centers c 
        ON c.id = pr.center   
WHERE 
        pr.req_date BETWEEN TO_DATE(TO_CHAR(CURRENT_DATE - INTERVAL '1 day', 'YYYY-MM-DD'), 'YYYY-MM-DD')
        AND TO_DATE(TO_CHAR(CURRENT_DATE + INTERVAL '1 day', 'YYYY-MM-DD'), 'YYYY-MM-DD')
        AND pr.center IN (:Scope)
        AND pr.request_type IN (1, 5, 6)