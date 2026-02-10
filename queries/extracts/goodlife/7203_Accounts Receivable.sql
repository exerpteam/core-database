-- The extract is extracted from Exerp on 2026-02-08
--  
SELECT
	p.external_id,
	p.center || 'p' || p.id as PersonID,
	p.firstname,
    p.lastname,
	ar.*
FROM 
	PERSONS p	
JOIN 
	ACCOUNT_RECEIVABLES ar 	
ON
	ar.CUSTOMERID = p.ID AND
	ar.CUSTOMERCENTER = p.CENTER

WHERE p.external_id IN ($$external$$)

