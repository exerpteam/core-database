WITH 
        override AS
        (
                with scope_center as 
                (
                WITH
                    RECURSIVE centers_in_area AS
                    (
                        SELECT
                            a.id,
                            a.parent,
                            ARRAY[id] AS chain_of_command_ids,
                            2         AS level
                        FROM
                            areas a
                        WHERE
                            a.types LIKE '%system%'
                        AND a.parent IS NULL
                        UNION ALL
                        SELECT
                            a.id,
                            a.parent,
                            array_append(cin.chain_of_command_ids, a.id) AS chain_of_command_ids,
                            cin.level + 1                                AS level
                        FROM
                            areas a
                        JOIN
                            centers_in_area cin
                        ON
                            cin.id = a.parent
                    )
                    ,
                    areas_total AS
                    (
                        SELECT
                            cin.id AS ID,
                            cin.level,
                            unnest(array_remove(array_agg(b.ID), NULL)) AS sub_areas
                        FROM
                            centers_in_area cin
                        LEFT JOIN
                            centers_in_area AS b -- join provides subordinates
                        ON
                            cin.id = ANY (b.chain_of_command_ids)
                        AND cin.level <= b.level
                        GROUP BY
                            1,2
                    )
                SELECT
                    'A'               AS "SCOPE_TYPE",
                    areas_total.ID    AS "SCOPE_ID",
                    c.ID              AS "CENTER_ID",
                    areas_total.level AS "LEVEL"
                FROM
                    areas_total
                LEFT JOIN
                    area_centers ac
                ON
                    ac.area = areas_total.sub_areas
                JOIN
                    centers c
                ON
                    ac.CENTER = c.id
                UNION ALL
                SELECT
                    'C'  AS "SCOPE_TYPE",
                    c.ID AS "SCOPE_ID",
                    c.ID AS "CENTER_ID",
                    999  AS "LEVEL"
                FROM
                    centers c
                UNION ALL
                SELECT
                    'G'  AS "SCOPE_TYPE",
                    0    AS "SCOPE_ID",
                    c.ID AS "CENTER_ID",
                    0    AS "LEVEL"
                FROM
                    centers c
                UNION ALL
                SELECT
                    'T'  AS "SCOPE_TYPE",
                    a.ID AS "SCOPE_ID",
                    c.id AS "CENTER_ID",
                    1    AS "LEVEL"
                FROM
                    areas a
                CROSS JOIN
                    centers c
                WHERE
                    a.id = a.root_area
                 )   
                SELECT 
                        "CENTER_ID",
                        id,
                        top_node_id,
                        time_config_id,
                        activity_group_id 
                FROM
                (  
                select 
                *,
                rank() over (partition BY coalesce(a.top_node_id, a.id), sc."CENTER_ID" ORDER BY sc."LEVEL" DESC) AS rnk
                from 
                activity a
                join scope_center sc
                ON 
                a.scope_type = sc."SCOPE_TYPE"
                AND a.scope_id = sc."SCOPE_ID"
                WHERE  
                  a.state = 'ACTIVE'
                ) 
                WHERE
                  rnk = 1
                )                        
SELECT DISTINCT
        CASE
                WHEN override.id IS NULL THEN a.id 
                ELSE override.id
        End as "Activity ID"
        ,a.id AS "Top Scope Activity ID"
        ,a.name AS "Activity Name"
        ,c.name AS "Club"
        ,c.id AS "ClubID"    
        ,ag.name AS "Activity Group"  
        ,CASE
                WHEN override.id IS NULL THEN sg.name
                ELSE osg.name
        END AS "Staff group"                 
        ,CASE a.ACTIVITY_TYPE 
                WHEN 1 THEN 'General' 
                WHEN 2 THEN 'Class' 
                WHEN 3 THEN 'Resource booking' 
                WHEN 4 THEN 'Staff booking' 
                WHEN 5 THEN 'Meeting' 
                WHEN 6 THEN 'Staff availability' 
                WHEN 7 THEN 'Resource availability' 
                WHEN 8 THEN 'ChildCare' 
                WHEN 9 THEN 'Course program' 
                WHEN 10 THEN 'Task' 
                WHEN 11 THEN 'Camp' 
                WHEN 12 THEN 'Camp elective' 
                ELSE 'Undefined' 
        END AS "Type"
        ,a.state AS "State"
FROM
        activity a
JOIN
        colour_groups cg
        ON cg.id = a.colour_group_id 
JOIN
        activity_group ag
        ON a.activity_group_id = ag.id
JOIN
        activity_resource_configs arc
        ON a.id = arc.activity_id  
JOIN
        booking_resource_groups brg
        ON brg.id = arc.booking_resource_group_id         
LEFT JOIN
        (
        WITH
            RECURSIVE centers_in_area AS
            (
                SELECT
                        a.id,
                        a.parent,
                        ARRAY[id] AS chain_of_command_ids,
                        1         AS level
                FROM
                        areas a
                WHERE
                        a.types LIKE '%system%'
                        AND a.parent IS NULL
                UNION ALL
                SELECT
                        a.id,
                        a.parent,
                        array_append(cin.chain_of_command_ids, a.id) AS chain_of_command_ids,
                        cin.level + 1                                AS level
                FROM
                        areas a
                JOIN
                        centers_in_area cin
                ON
                        cin.id = a.parent
            )
        SELECT
                cin.id                                      AS ID,
                unnest(array_remove(array_agg(b.ID), NULL)) AS sub_areas
        FROM
                centers_in_area cin
        LEFT JOIN
                centers_in_area AS b -- join provides subordinates
                ON cin.id = ANY (b.chain_of_command_ids)
                AND cin.level <= b.level
        GROUP BY
                1
        ) areas_total
        ON areas_total.id = a.scope_id
        AND a.scope_type = 'A'
LEFT JOIN
        area_centers ac
        ON ac.area = areas_total.sub_areas
JOIN
        centers c
        ON a.scope_type IN ('T','G')
        OR  (a.scope_type = 'C'AND a.scope_id = c.id)
        OR  (a.scope_type = 'A'AND ac.CENTER = c.id) 
LEFT JOIN
        override
        ON override."CENTER_ID" = c.id
        AND override.top_node_id IS NOT NULL
        AND a.id = override.top_node_id
LEFT JOIN 
        evolutionwellness.activity_staff_configurations asg
        ON asg.activity_id = a.id
LEFT JOIN
        evolutionwellness.staff_groups sg
        ON sg.id = asg.staff_group_id                 
LEFT JOIN
        evolutionwellness.activity_staff_configurations oasg
        ON oasg.activity_id = override.id 
LEFT JOIN
        evolutionwellness.staff_groups osg
        ON osg.id = oasg.staff_group_id                    
WHERE
        c.id IN (:Scope)
		AND a.State = 'ACTIVE'
        --AND
        --a.name = 'ADVANCE STEP