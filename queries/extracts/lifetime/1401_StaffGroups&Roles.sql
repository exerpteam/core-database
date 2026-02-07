SELECT
        rolestable.external_id,        
        rolestable.center || 'p' || rolestable.id AS PersonId,
        rolestable.empCenter || 'emp' || rolestable.empId AS EmployeeId,
		rolestable.firstname,
		rolestable.lastname,
        rolestable.status,
        rolestable.roleslist,
        sgtable.staffGroupList
FROM
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
                        FROM lifetime.persons p
                        JOIN lifetime.employees e ON p.center = e.personcenter AND p.id = e.personid AND e.blocked = false 
                        WHERE
                                p.center IN (:Scope)
                                AND p.persontype = 2
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
                LEFT JOIN lifetime.employeesroles er ON er.center = t1.empCenter AND er.id = t1.empId
                LEFT JOIN lifetime.roles r ON er.roleid = r.id AND r.blocked = false AND r.is_action = false
                LEFT JOIN lifetime.centers c ON c.id = er.scope_id AND er.scope_type = 'C'
                LEFT JOIN lifetime.areas a ON a.id = er.scope_id AND er.scope_type IN ('A','T')
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
) rolestable
LEFT JOIN
(
        SELECT
                t1.center,
                t1.id,
                STRING_AGG(CAST(t1.ScopesSG AS TEXT), ' ; ') AS staffGroupList
        FROM
        (
                SELECT
                        p.center,
                        p.id,
                        (CASE
                                WHEN psg.scope_type = 'C' THEN sg.name || ' (' || c.name || ')'
                                WHEN psg.scope_type IN ('A','T') THEN sg.name || ' (' || a.name || ')'
                                ELSE NULL
                       END) ScopesSG
                FROM lifetime.persons p
                LEFT JOIN lifetime.person_staff_groups psg ON p.center = psg.person_center AND p.id = psg.person_id
                LEFT JOIN lifetime.staff_groups sg ON sg.id = psg.staff_group_id AND sg.state = 'ACTIVE'
                LEFT JOIN lifetime.centers c ON c.id = psg.scope_id AND psg.scope_type = 'C'
                LEFT JOIN lifetime.areas a ON a.id = psg.scope_id AND psg.scope_type IN ('A','T')
                WHERE
                        p.center IN (:Scope)
                        AND p.persontype = 2
                        AND p.STATUS IN (0,1,2,3,6,9)
        ) t1
        GROUP BY 
                t1.center,
                t1.id
) sgtable
ON
        rolestable.center = sgtable.center
        AND rolestable.id = sgtable.id
