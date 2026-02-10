-- The extract is extracted from Exerp on 2026-02-08
--  
SELECT
p.center ||'p'|| p.id AS memberid,
CASE pr.STATE WHEN 1 THEN 'New' WHEN 2 THEN 'Sent' WHEN 3 THEN 'Done' WHEN 4 THEN 'Done, manual' WHEN 5 THEN 'Rejected, clearinghouse' WHEN 6 THEN 'Rejected, bank' WHEN 7 THEN 'Rejected, debtor' WHEN 8 THEN 'Cancelled' WHEN 10 THEN 'Reversed, new' WHEN 11 THEN 'Reversed , sent' WHEN 12 THEN 'Failed, not creditor' WHEN 13 THEN 'Reversed, rejected' WHEN 14 THEN 'Reversed, confirmed' WHEN 17 THEN 'Failed, payment revoked' WHEN 18 THEN 'Done Partial' WHEN 19 THEN 'Failed, Unsupported' WHEN 20 THEN 'Require approval' WHEN 21 THEN 'Fail, debt case exists' WHEN 22 THEN 'Failed, timed out' ELSE 'Undefined' END AS payment_request_state,
prs.requested_amount,
prs.open_amount,
prs.ref,
prs.paid_state
FROM
persons p
JOIN
account_receivables ar
ON
ar.customercenter = p.center
AND ar.customerid = p.id
JOIN
payment_requests pr
ON
pr.center = ar.center
AND pr.id = ar.id
JOIN
payment_request_specifications prs
ON
prs.center = pr.center
AND prs.id = pr.id
AND prs.subid = pr.subid
WHERE
prs.open_amount = 0
AND pr.state = 1
--AND pr.request_type != 8
AND pr.clearinghouse_id = 4
AND p.center IN (:scope)