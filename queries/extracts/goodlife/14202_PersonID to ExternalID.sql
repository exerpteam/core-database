-- The extract is extracted from Exerp on 2026-02-08
-- Returns Person External ID when inputting Person ID.
SELECT 
	p.center || 'p' || p.id AS PersonID,
	p.external_ID

FROM persons p

WHERE 
	p.center || 'p' || p.id IN ($$personID$$)