SELECT  
	p.center || 'p' || p.id,
	p.fullname

FROM PERSONS p
WHERE p.center || 'p' || p.id IN ($$PersonID$$)