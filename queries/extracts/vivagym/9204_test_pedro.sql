-- The extract is extracted from Exerp on 2026-02-08
--  
SELECT
        ar.customercenter || 'p' || ar.customerid AS PersonId,
        CASE pr.STATE WHEN 1 THEN 'New' WHEN 2 THEN 'Sent' WHEN 3 THEN 'Done' WHEN 4 THEN 'Done, manual' WHEN 5 THEN 'Rejected, clearinghouse' WHEN 6 THEN 'Rejected, bank' WHEN 7 THEN 'Rejected, debtor' WHEN 8 THEN 'Cancelled' WHEN 10 THEN 'Reversed, new' WHEN 11 THEN 'Reversed , sent' WHEN 12 THEN 'Failed, not creditor' WHEN 13 THEN 'Reversed, rejected' WHEN 14 THEN 'Reversed, confirmed' WHEN 17 THEN 'Failed, payment revoked' WHEN 18 THEN 'Done Partial' WHEN 19 THEN 'Failed, Unsupported' WHEN 20 THEN 'Require approval' WHEN 21 THEN 'Fail, debt case exists' WHEN 22 THEN 'Failed, timed out' ELSE 'Undefined' END AS payment_request_state,
        pr.req_date,
        pr.request_type,
        ch.name AS clearinghouse_name,
        pr.req_amount,
        pr.reject_fee_invline_center,
        longtodatec(art.entry_time, art.center) AS transaction_entry_time,
        p.fullname AS employee_name,
        art.employeecenter || 'emp' || art.employeeid AS employeeId,
        art.amount AS transaction_amount,
        art.text AS transaction_text,
        art.ref_type AS transaction_type
FROM vivagym.payment_requests pr
JOIN vivagym.clearinghouses ch ON pr.clearinghouse_id = ch.id
JOIN vivagym.account_receivables ar ON pr.center = ar.center AND pr.id = ar.id
LEFT JOIN vivagym.ar_trans art ON ar.center = art.center AND ar.id = art.id AND art.entry_time >= DATETOLONGC(TO_CHAR(TO_DATE('2023-01-17','YYYY-MM-DD'),'YYYY-MM-DD'), art.center) AND (art.amount = 3 OR art.amount = 4)
LEFT JOIN vivagym.employees e ON e.center = art.employeecenter AND e.id = art.employeeid
LEFT JOIN vivagym.persons p ON e.personcenter = p.center AND e.personid = p.id
WHERE
        pr.req_date BETWEEN TO_DATE('2023-01-17','YYYY-MM-DD') AND TO_DATE('2023-01-18','YYYY-MM-DD')
        AND pr.reject_fee_invline_center IS NOT NULL
