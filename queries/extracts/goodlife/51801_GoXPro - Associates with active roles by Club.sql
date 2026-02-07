SELECT 
	p.firstname as FirstName,
	p.lastname as LastName,
	e.center || 'emp' || e.id AS ActiveLoginID,
	p.center as ActiveLoginCenter,
	p.center || 'p' || p.id AS PersonID,
	p.external_id as ExternalID,
	pea.txtvalue as Email,
	CASE e.blocked
		WHEN FALSE
		THEN 'Active'
		WHEN TRUE
		THEN 'Blocked'
		ELSE 'UNKNOWN'
	END AS "Login Status",
	r.rolename as RoleName,
	CASE
                        WHEN er.scope_type = 'C' THEN c.name
                        WHEN er.scope_type = 'A' THEN a.name
                        WHEN er.scope_type = 'T' THEN 'System'
                        WHEN er.scope_type = 'G' THEN 'Global'
                        ELSE 'Unknown'
                END as RoleScope
FROM
	Persons p
JOIN
	Employees e
ON
	e.personcenter = p.center
AND
	e.personid = p.id
JOIN
        goodlife.person_ext_attrs pea
        on pea.personcenter = p.center
        AND pea.personid = p.id
        AND pea.name = '_eClub_Email'
JOIN employeesroles er
                ON er.id = e.id AND er.center = e.center
JOIN roles r
                ON r.id = er.roleid
LEFT JOIN goodlife.centers c
        on er.scope_type = 'C' and er.scope_id = c.id
LEFT JOIN goodlife.areas a
        on er.scope_type = 'A' and er.scope_id = a.id

WHERE p.persontype = 2
	AND e.CENTER IN (:center)
	and e.blocked = false
	and r.rolename IN ('Front Desk Manager',
'Senior Motivator',
'Motivator',
'Fitness Trainer',
'Fitness Advisor',
'Assistant Fitness Manager',
'Fitness Manager',
'Assistant General Manager',
'General Manager',
'Personal Trainer')