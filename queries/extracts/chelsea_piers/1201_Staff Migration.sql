-- The extract is extracted from Exerp on 2026-02-08
--  
SELECT
		p.fullname,
        p.center || 'p' || p.id AS PersonID,
        p.external_id AS ExternalID,
        pea.txtvalue AS MosoID,
        e.center || 'emp' || e.id AS EmployeeID,
        rolestable.roleslist
FROM 
        chelseapiers.persons p
JOIN
        chelseapiers.person_ext_attrs pea ON pea.personcenter = p.center AND pea.personid = p.id AND pea.name = '_eClub_OldSystemPersonId'
JOIN
        chelseapiers.employees e ON p.center = e.personcenter AND p.id = e.personid
LEFT JOIN
(
        SELECT
                t2.center,
                t2.id,
                t2.empCenter,
                t2.empId,
                t2.external_id,
                t2.firstname,
                t2.lastname,
                (CASE t2.status
                        WHEN 0 THEN 'LEAD'
                        WHEN 1 THEN 'ACTIVE'
                        WHEN 2 THEN 'INACTIVE'
                        WHEN 3 THEN 'TEMPORARYINACTIVE'
                        WHEN 6 THEN 'PROSPECT'
                        WHEN 9 THEN 'CONTACT'
                        ELSE 'UNKNOWN'
                END) AS status,
                STRING_AGG(CAST(t2.ScopesRoles AS TEXT), ' ; ') AS roleslist
        FROM
        (
                SELECT
                        t1.center,
                        t1.id,
                        t1.empCenter,
                        t1.empId,
                        t1.status,
                        t1.external_id,
                        t1.firstname,
                        t1.lastname,
                        (CASE
                                WHEN er.scope_type = 'C' THEN r.rolename || ' (' || c.name || ')'
                                WHEN er.scope_type IN ('A','T') THEN r.rolename || ' (' || a.name || ')'
                                ELSE NULL
                        END) ScopesRoles
                FROM
                (
                        SELECT 
                                p.center,
                                p.id,
                                p.status,
                                p.external_id,
                                p.firstname,
                                p.lastname,
                                e.center AS empCenter,
                                e.id AS empId
                        FROM persons p
                        JOIN employees e ON p.center = e.personcenter AND p.id = e.personid AND e.blocked = false 
                        WHERE
                                p.persontype = 2
                                AND p.STATUS IN (0,1,2,3,6,9)
                                AND 
                                (
                                        e.passwd_never_expires = true
                                        OR
                                        e.passwd_never_expires = false AND
                                                                        (
                                                                                e.passwd_expiration IS NULL 
                                                                                OR 
                                                                                e.passwd_expiration > current_date
                                                                        )
                                )
                ) t1
                LEFT JOIN employeesroles er ON er.center = t1.empCenter AND er.id = t1.empId
                LEFT JOIN roles r ON er.roleid = r.id AND r.blocked = false AND r.is_action = false
                LEFT JOIN centers c ON c.id = er.scope_id AND er.scope_type = 'C'
                LEFT JOIN areas a ON a.id = er.scope_id AND er.scope_type IN ('A','T')
        ) t2
        GROUP BY 
                t2.center,
                t2.id,
                t2.empCenter,
                t2.empId,
                t2.status,
		t2.external_id,
		t2.firstname,
		t2.lastname
) rolestable ON rolestable.empCenter = e.Center AND rolestable.empId = e.Id
WHERE
        p.persontype = 2
        AND pea.txtvalue IS NOT NULL