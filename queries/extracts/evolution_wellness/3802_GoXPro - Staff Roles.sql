-- The extract is extracted from Exerp on 2026-02-08
--  
WITH RECURSIVE centers_in_area AS
        (
                SELECT
                        a.id,
                        a.parent,
                        ARRAY[id] AS chain_of_command_ids,
                        2         AS level
                FROM areas a
                WHERE
                        a.types LIKE '%system%'
                        AND a.parent IS NULL
                UNION ALL
                SELECT
                        a.id,
                        a.parent,
                        array_append(cin.chain_of_command_ids, a.id) AS chain_of_command_ids,
                        cin.level + 1                                AS level
                FROM areas a
                JOIN centers_in_area cin ON cin.id = a.parent
        ),
        areas_total AS
        (
                SELECT
                        cin.id AS ID,
                        cin.level,
                        unnest(array_remove(array_agg(b.ID), NULL)) AS sub_areas
                FROM centers_in_area cin
                LEFT JOIN centers_in_area AS b -- join provides subordinates
                        ON cin.id = ANY (b.chain_of_command_ids)
                        AND cin.level <= b.level
                GROUP BY
                        1,2
        ),
        tree_shape AS
        (
                SELECT
                        'A'               AS SCOPE_TYPE,
                        areas_total.ID    AS SCOPE_ID,
                        ac.CENTER         AS CENTER_ID,
                        areas_total.level AS level_scope
                FROM areas_total
                LEFT JOIN area_centers ac
                        ON ac.area = areas_total.sub_areas
                JOIN centers c
                        ON ac.CENTER = c.id
        ),
        system_scope AS
        (
                SELECT
                        *
                FROM centers
        )                                            
SELECT
        *
FROM
        (
        SELECT
                p.external_id AS "External ID"
                ,CASE
                        WHEN er.scope_type = 'C' THEN er.scope_id
                        WHEN er.scope_type = 'A' THEN ts.center_id
                        ELSE ss.id
                END AS "Center ID"
				,CASE
                        WHEN r.rolename = 'EVO - Fitness Manager' THEN 'EW_FM'
						WHEN r.rolename = 'EVO - Club General Manager' THEN 'EW_CM'
 						WHEN r.rolename = 'EVO - Head of Fitness' THEN 'EW_NM'
                        WHEN r.rolename = 'EVO - PT Admin' THEN 'EW_CA'
                        ELSE 'Not a GoXPro role'
                END AS "Role Name"
        FROM employees e
        JOIN persons p
                ON p.id = e.personid AND p.center = e.personcenter
        JOIN employeesroles er
                ON er.id = e.id AND er.center = e.center
        JOIN roles r
                ON r.id = er.roleid
        LEFT JOIN tree_shape ts
                ON ts.scope_id = er.scope_id
                AND er.scope_type = 'A'
        LEFT JOIN system_scope ss
                ON er.scope_type = 'T' 
		AND e.blocked IS FALSE        
        )t
WHERE
        t."Center ID" != 1
        AND
        t."External ID" = :External_ID
		AND t."Role Name" IN ('EW_FM', 'EW_CM', 'EW_NM', 'EW_CA')