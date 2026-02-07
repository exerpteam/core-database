-- This is the version from 2026-02-05
--  
SELECT
acl.*,
p.external_id
FROM
persons p
JOIN
account_receivables ar
ON
ar.customercenter = p.center
AND ar.customerid = p.id
AND ar.ar_type = 4
JOIN
payment_agreements pa
ON
pa.center = ar.center
AND pa.id = ar.id
JOIN
agreement_change_log acl
ON
acl.agreement_center = pa.center
AND acl.agreement_id = pa.id
AND acl.agreement_subid = pa.subid
WHERE
pa.clearinghouse = 2
AND pa.state != 4
AND acl.clearing_in IS NOT NULL