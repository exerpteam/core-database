SELECT
        ar.customercenter || 'p' || ar.customerid AS person_id,
        ch.name AS clearinghouse_name,
        pag.ref AS payment_agr_ref,
        CASE pag.STATE WHEN 1 THEN 'Created' WHEN 2 THEN 'Sent' WHEN 3 THEN 'Failed' WHEN 4 THEN 'OK' WHEN 5 THEN 'Ended = bank' WHEN 6 THEN 'Ended = clearing house' WHEN 7 THEN 'Ended = debtor' WHEN 8 THEN 'Cancelled = not sent' WHEN 9 THEN 'Cancelled = sent' WHEN 10 THEN 'Ended = creditor' WHEN 11 THEN 'No agreement' WHEN 12 THEN 'Cash payment (deprecated)' WHEN 13 THEN 'Agreement not needed (invoice payment)' WHEN 14 THEN 'Agreement information incomplete' WHEN 15 THEN 'Transfer' WHEN 16 THEN 'Agreement Recreated' WHEN 17 THEN 'Signature missing' ELSE 'UNDEFINED' END AS payment_agr_state,
        pag.active AS payment_agr_active,
        CASE pr.STATE
                WHEN 1 THEN 'New' 
                WHEN 2 THEN 'Sent' 
                WHEN 3 THEN 'Done' 
                WHEN 4 THEN 'Done, manual' 
                WHEN 5 THEN 'Rejected, clearinghouse' 
                WHEN 6 THEN 'Rejected, bank' 
                WHEN 7 THEN 'Rejected, debtor' 
                WHEN 8 THEN 'Cancelled' 
                WHEN 10 THEN 'Reversed, new' 
                WHEN 11 THEN 'Reversed , sent' 
                WHEN 12 THEN 'Failed, not creditor' 
                WHEN 13 THEN 'Reversed, rejected' 
                WHEN 14 THEN 'Reversed, confirmed' 
                WHEN 17 THEN 'Failed, payment revoked' 
                WHEN 18 THEN 'Done Partial' 
                WHEN 19 THEN 'Failed, Unsupported' 
                WHEN 20 THEN 'Require approval' 
                WHEN 21 THEN 'Fail, debt case exists' 
                WHEN 22 THEN 'Failed, timed out' 
                ELSE 'Undefined' 
        END AS payment_request_state,        
        (CASE pr.request_type
                WHEN 1 THEN 'Payment'
                WHEN 6 THEN 'Representation'
                ELSE 'Undefined'
        END) AS payment_request_type,
        pr.full_reference AS payment_request_full_reference,
        pr.req_amount,
        pr.req_date,
        prs.open_amount AS open_amount
        
FROM vivagym.payment_requests pr
JOIN vivagym.centers c ON pr.center = c.id AND c.country = 'PT'
JOIN vivagym.payment_request_specifications prs ON pr.inv_coll_center = prs.center AND pr.inv_coll_id = prs.id AND pr.inv_coll_subid = prs.subid
JOIN vivagym.payment_agreements pag ON pag.center = pr.center AND pag.id = pr.id AND pag.subid = pr.agr_subid
JOIN vivagym.clearinghouses ch ON pag.clearinghouse = ch.id
JOIN vivagym.payment_accounts pac ON pag.center = pac.center AND pag.id = pac.id 
JOIN vivagym.account_receivables ar ON pac.center = ar.center AND pac.id = ar.id
WHERE 
        length(pag.ref) != 15