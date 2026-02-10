-- The extract is extracted from Exerp on 2026-02-08
-- ST-16930 - GXP Integration
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
                WHERE c.id NOT IN (5, 16, 18, 24, 37, 38, 43, 45, 46, 62, 67, 68, 72, 75, 79, 82, 85, 104, 105, 106, 108, 111, 113, 117, 118, 119, 120, 121, 122, 124, 125, 129, 131, 136, 137, 140, 144, 152, 153, 154, 156, 158, 163, 164, 167, 175, 176, 182, 187, 188, 191, 204, 207, 214, 216, 218, 222, 224, 235, 244, 251, 252, 261, 263, 270, 303, 304, 305, 307, 314, 316, 320, 322, 335, 535)
        ),
        system_scope AS
        (
                SELECT
                        *
                FROM centers c
                where c.id NOT IN (5, 16, 18, 24, 37, 38, 43, 45, 46, 62, 67, 68, 72, 75, 79, 82, 85, 104, 105, 106, 108, 111, 113, 117, 118, 119, 120, 121, 122, 124, 125, 129, 131, 136, 137, 140, 144, 152, 153, 154, 156, 158, 163, 164, 167, 175, 176, 182, 187, 188, 191, 204, 207, 214, 216, 218, 222, 224, 235, 244, 251, 252, 261, 263, 270, 303, 304, 305, 307, 314, 316, 320, 322, 335, 535)
                
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
WHEN r.rolename = 'Configuration' THEN 'GL_AA'

WHEN r.rolename = 'Front Desk Manager' THEN 'GL_CV'
WHEN r.rolename = 'Senior Motivator' THEN 'GL_CV'
WHEN r.rolename = 'Motivator' THEN 'GL_CV'
WHEN r.rolename = 'Senior Fitness Trainer' THEN 'GL_CV'
WHEN r.rolename = 'Fitness Trainer' THEN 'GL_CV'
WHEN r.rolename = 'Senior Fitness Coach' THEN 'GL_CV'
WHEN r.rolename = 'Fitness Coach' THEN 'GL_CV'
WHEN r.rolename = 'Fitness Advisor' THEN 'GL_CV'
WHEN r.rolename = 'PT Regional' THEN 'GL_NA'
WHEN r.rolename = 'Assistant Fitness Manager' THEN 'GL_CA'
WHEN r.rolename = 'Fitness Manager' THEN 'GL_CA'
WHEN r.rolename = 'Assistant General Manager' THEN 'GL_CA'
WHEN r.rolename = 'General Manager' THEN 'GL_CA'
    
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
        WHERE
                er.scope_id NOT IN (5, 16, 18, 24, 37, 38, 43, 45, 46, 62, 67, 68, 72, 75, 79, 82, 85, 104, 105, 106, 108, 111, 113, 117, 118, 119, 120, 121, 122, 124, 125, 129, 131, 136, 137, 140, 144, 152, 153, 154, 156, 158, 163, 164, 167, 175, 176, 182, 187, 188, 191, 204, 207, 214, 216, 218, 222, 224, 235, 244, 251, 252, 261, 263, 270, 303, 304, 305, 307, 314, 316, 320, 322, 335, 535)
                AND e.blocked IS FALSE
            )t
WHERE
        t."Center ID" != 1
        AND
        t."External ID" = :External_ID
AND t."Role Name" IN ('GL_NA', 'GL_CA', 'GL_CV', 'GL_AA')



