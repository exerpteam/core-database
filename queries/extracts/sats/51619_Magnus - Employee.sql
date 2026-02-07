SELECT * 
FROM EMPLOYEES e, BI_PERSONS p
WHERE	p.center = e.personcenter
  		AND p.id = e.id
	AND p.Lastname = 'Nordlund'