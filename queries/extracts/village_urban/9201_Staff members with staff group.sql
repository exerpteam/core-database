SELECT
                t1.center || 'p' || t1.id AS PERSON_KEY,
				t1.STATUS,
                LISTAGG(t1.ScopesSG, ' ; ') WITHIN GROUP (ORDER BY t1.ScopesSG) AS staffGroupList
        FROM
        (
                SELECT
                        p.center,
                        p.id,
						p.STATUS,
                        (CASE
                                WHEN psg.scope_type = 'C' THEN sg.name || ' (' || c.name || ')'
                                WHEN psg.scope_type IN ('A','T') THEN sg.name || ' (' || a.name || ')'
                                ELSE NULL
                       END) ScopesSG
                FROM persons p
                LEFT JOIN person_staff_groups psg ON p.center = psg.person_center AND p.id = psg.person_id
                LEFT JOIN staff_groups sg ON sg.id = psg.staff_group_id AND sg.state = 'ACTIVE'
                LEFT JOIN centers c ON c.id = psg.scope_id AND psg.scope_type = 'C'
                LEFT JOIN areas a ON a.id = psg.scope_id AND psg.scope_type IN ('A','T')
                WHERE
                        p.persontype = 2
                        AND p.STATUS IN (0,1,2,3,6,9)
        ) t1
        GROUP BY 
                t1.center,
                t1.id,
				t1.STATUS

