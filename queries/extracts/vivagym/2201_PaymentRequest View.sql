-- The extract is extracted from Exerp on 2026-02-08
--  
WITH PARAMS AS MATERIALIZED
(
        SELECT
                TO_DATE(:FromDate,'YYYY-MM-DD') AS fromDate,
                TO_DATE(:ToDate,'YYYY-MM-DD') AS toDate,
                c.id AS centerId
        FROM 
                centers c
        WHERE 
                c.id IN (:Scope)
)
SELECT 
        ch.name,
        ar.customercenter || 'p' || ar.customerid AS PersonId,
         case 
        when p.external_id is null
        then p2.external_id
        else p.external_id END as external_id,  
        (CASE pr.state
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
        END) AS pr_state,
        pr.req_amount,
        pr.req_date,
        pr.xfr_info as rejection_details,
        pr.rejected_reason_code,
        pr.due_date,
        pr.full_reference,
        (CASE pr.request_type
                WHEN 1 THEN 'Payment' 
                WHEN 2 THEN 'Debt Collection' 
                WHEN 3 THEN 'Reversal' 
                WHEN 4 THEN 'Reminder' 
                WHEN 5 THEN 'Refund' 
                WHEN 6 THEN 'Representation' 
                WHEN 7 THEN 'Legacy' 
                WHEN 8 THEN 'Zero' 
                WHEN 9 THEN 'Service Charge' 
                ELSE 'Unknown' 
        END) AS Request_type,
        pr.employee_center || 'emp' || pr.employee_id as employeeid,
        pag.clearinghouse_ref,
        pea.txtvalue AS email,
        NULL AS Exerp_Comment,
        pr.reject_fee_invline_center

FROM
        vivagym.payment_requests pr
JOIN
        params par ON par.centerId = pr.center
JOIN
        vivagym.centers c ON pr.center = c.id
JOIN 
        vivagym.clearinghouses ch ON ch.id = pr.clearinghouse_id
JOIN
        vivagym.payment_agreements pag ON pag.center = pr.center AND pag.id = pr.id AND pag.subid = pr.agr_subid
JOIN
        vivagym.payment_accounts pac ON pag.center = pac.center AND pag.id = pac.id
JOIN
        vivagym.account_receivables ar ON pac.center = ar.center AND pac.id = ar.id
JOIN
        vivagym.persons p ON ar.customercenter = p.center AND ar.customerid = p.id
LEFT JOIN 
        vivagym.person_ext_attrs pea ON p.center = pea.personcenter AND p.id = pea.personid  AND pea.name = '_eClub_Email'
left join persons p2
on p.transfers_current_prs_center = p2.center
and p.transfers_current_prs_id = p2.id      
WHERE
        pr.req_date BETWEEN par.fromDate AND par.toDate
        AND pr.state NOT IN (8) -- CANCELLED 