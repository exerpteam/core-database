-- The extract is extracted from Exerp on 2026-02-08
-- Used for data import for phased rollout. https://clublead.atlassian.net/browse/ST-16948
SELECT 
	p.firstname as FirstName,
	p.lastname as LastName,
	e.center || 'emp' || e.id AS ActiveLoginID,
	p.center as ActiveLoginCenter,
	p.center || 'p' || p.id AS PersonID,
	p.external_id as ExternalID,
	pea.txtvalue as Email,
	pea_pro.txtvalue as GoXProPTStatus,
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
LEFT JOIN
        goodlife.person_ext_attrs pea_pro
        on pea_pro.personcenter = p.center
        AND pea_pro.personid = p.id
        AND pea_pro.name = 'GoXProPTStatus'
JOIN employeesroles er
                ON er.id = e.id AND er.center = e.center
JOIN roles r
                ON r.id = er.roleid
LEFT JOIN goodlife.centers c
        on er.scope_type = 'C' and er.scope_id = c.id
LEFT JOIN goodlife.areas a
        on er.scope_type = 'A' and er.scope_id = a.id

WHERE p.persontype = 2
	AND e.CENTER = ANY (
    string_to_array(:centers_text, ',')::int[]
)
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