WITH PARAMS AS MATERIALIZED
(
        SELECT
				dateToLongC(TO_CHAR(to_date(:fromdate,'YYYY-MM-DD'),'YYYY-MM-DD'),c.id) as fromdate,
                dateToLongC(TO_CHAR(to_date(:todate,'YYYY-MM-DD'),'YYYY-MM-DD'),c.id) + (24*60*60*1000) as todate,
                c.id AS centerId,
                c.name AS centerName,
                c.country
        FROM 
                centers c
)
SELECT 
        par.country,
        par.centerId,
        par.centerName,
        ch.name AS clearinghousename,
        ar.customercenter || 'p' || ar.customerid AS PersonId,
         case 
        when p.external_id is null
        then p2.external_id
        else p.external_id END as external_id, 
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
        pr.due_date,
        pr.xfr_info,
        pr.xfr_date,
        pr.rejected_reason_code,
        pr.employee_center || 'emp' || pr.employee_id as employeeid,
        (CASE 
                WHEN pr.reject_fee_invline_center IS NOT NULL THEN 'YES'
                ELSE 'NO'
        END) has_rejection_fee
FROM
        vivagym.payment_requests pr
JOIN
        params par ON par.centerId = pr.center
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
left join persons p2
on p.transfers_current_prs_center = p2.center
and p.transfers_current_prs_id = p2.id
WHERE
        pr.last_modified BETWEEN par.fromDate AND par.toDate
ORDER BY 1, 2, 4