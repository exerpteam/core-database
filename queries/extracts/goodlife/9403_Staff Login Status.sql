SELECT 
	e.center || 'emp' || e.id AS LoginID,
	p.center,
	p.center || 'p' || p.id AS PersonID,
	p.external_id,
	p.fullname, 
	CASE e.blocked
		WHEN FALSE
		THEN 'Active'
		WHEN TRUE
		THEN 'Blocked'
		ELSE 'UNKNOWN'
	END AS "Login Status"
FROM
	Persons p
JOIN
	Employees e
ON
	e.personcenter = p.center
AND
	e.personid = p.id

WHERE p.persontype = 2
	AND e.CENTER IN ($$center$$)