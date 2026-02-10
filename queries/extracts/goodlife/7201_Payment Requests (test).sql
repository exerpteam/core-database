-- The extract is extracted from Exerp on 2026-02-08
-- Nathans Payment Requests Query
SELECT
	p.center || 'p' || p.id as PersonID,
	p.firstname,
    p.lastname,
	ar.ar_type,
	ar.balance,
	pr.*
FROM 
	ACCOUNT_RECEIVABLES ar 
JOIN 
	PERSONS p
ON
	ar.CUSTOMERID = p.ID AND
	ar.CUSTOMERCENTER = p.CENTER
JOIN
	PAYMENT_REQUESTS pr
ON
	ar.ID = pr.ID AND
	ar.CENTER = pr.CENTER
-- WHERE 
--	pr.req_date = '07-28-2017'
LIMIT 100