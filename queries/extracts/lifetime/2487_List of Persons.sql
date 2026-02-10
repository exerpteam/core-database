-- The extract is extracted from Exerp on 2026-02-08
--  
SELECT  
	p.center || 'p' || p.id,
	p.fullname

FROM PERSONS p
WHERE p.center || 'p' || p.id IN ($$PersonID$$)