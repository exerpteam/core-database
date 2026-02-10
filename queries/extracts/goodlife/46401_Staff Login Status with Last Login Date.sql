-- The extract is extracted from Exerp on 2026-02-08
-- Created For: Sandra to check Exerp user status for certain associates
Created By: Sandra Gupta
Date Added: 11.14.23
SELECT 
	e.center || 'emp' || e.id AS LoginID,
	e.last_login,
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