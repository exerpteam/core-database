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
        c.name as Club
        ,p.center||'p'||p.id as PersonID
        ,emp.center||'emp'||emp.id AS EmpID 
        ,p.nickname AS Fullname
        ,p.fullname as NickName
        ,pclsp.new_value AS Staff_ExternalID
        ,CASE
                WHEN empr.scope_type = 'C' THEN c1.name
                WHEN empr.scope_type = 'A' THEN a1.name
                WHEN empr.scope_type = 'T' THEN 'System'
                ELSE NULL
        END AS RoleScope
        ,r.rolename
        ,CASE
                WHEN psg.scope_type = 'C' THEN c2.name
                WHEN psg.scope_type = 'A' THEN a2.name
                WHEN psg.scope_type = 'T' THEN 'System'
                ELSE NULL
        END AS RoleScope
        ,sg.name AS StaffGroup
        ,psg.salary
FROM 
        evolutionwellness.persons p 
LEFT JOIN
        evolutionwellness.employees emp
        ON emp.personcenter = p.center
        AND emp.personid = p.id
        AND emp.blocked IS FALSE
LEFT JOIN
        evolutionwellness.employeesroles empr
        ON empr.center = emp.center
        AND empr.id = emp.id
LEFT JOIN
        evolutionwellness.roles r
        ON r.id = empr.roleid
LEFT JOIN
        evolutionwellness.areas a1
        ON a1.id = empr.scope_id
        AND empr.scope_type = 'A'     
LEFT JOIN
        evolutionwellness.centers c1
        ON c1.id = empr.scope_id
        AND empr.scope_type = 'C'            
LEFT JOIN
        evolutionwellness.person_staff_groups psg
        ON psg.person_center = p.center
        AND psg.person_id = p.id
LEFT JOIN
        evolutionwellness.staff_groups sg
        ON sg.id = psg.staff_group_id   
LEFT JOIN
        evolutionwellness.areas a2
        ON a2.id = psg.scope_id
        AND psg.scope_type = 'A' 
LEFT JOIN
        evolutionwellness.centers c2
        ON c2.id = psg.scope_id
        AND psg.scope_type = 'C' 
JOIN
        evolutionwellness.centers c
        ON p.center = c.id    
LEFT JOIN
            person_change_logs pclsp
        ON pclsp.person_center = p.center
        AND pclsp.person_id = p.id
        AND pclsp.CHANGE_ATTRIBUTE = '_eClub_StaffExternalId'                                                                        
WHERE
        p.persontype = 2
        AND
        p.center IN (:Scope)