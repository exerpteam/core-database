-- The extract is extracted from Exerp on 2026-02-08
-- This was meant to be used for club closures, to check that all Staff Login’s had been blocked. It shows all logins and their status (Active, or Blocked) – as the club closing process is still being sorted out. 
SELECT 
	e.center || 'emp' || e.id AS LoginID,
	p.center,
	p.center || 'p' || p.id AS PersonID,
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