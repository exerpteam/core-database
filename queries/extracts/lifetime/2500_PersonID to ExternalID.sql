SELECT 
	p.center || 'p' || p.id AS PersonID,
	p.external_ID

FROM persons p

WHERE 
	p.center || 'p' || p.id IN ($$personID$$)