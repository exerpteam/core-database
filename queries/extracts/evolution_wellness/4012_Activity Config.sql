-- The extract is extracted from Exerp on 2026-02-08
--  
WITH 
        availability AS
        (
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
        activity_availability AS
        (
                SELECT  
                        a.*
                FROM evolutionwellness.activity a
                LEFT JOIN evolutionwellness.activity topact ON a.top_node_id = topact.id
                WHERE
                        a.state = 'ACTIVE'
                        AND a.top_node_id IS NULL
                        AND a.availability != ''
        ),
        activity_availability_unnested AS
        (
                SELECT 
                          id,
                          name,
                          scope_type,
                          scope_id,
                          state,
                          activity_type,
                          substring(availability_value,1,1) AS availability_scope_type,
                          CAST(substring(availability_value,2,length(availability_value)-1) AS INT) AS availability_scope_id,
                          availability_value
                FROM
                (
                        SELECT 
                                id,
                                name,
                                scope_type,
                                scope_id,
                                state,
                                activity_type,
                                unnest(string_to_array(availability, ',')) AS availability_value
                        FROM activity_availability
                ) AS expanded_rows
        )
        SELECT
                aau.*,
                ts.center_id    
        FROM activity_availability_unnested aau
        JOIN tree_shape ts 
                ON aau.availability_scope_type  = ts.SCOPE_TYPE
                AND aau.availability_scope_id = ts.SCOPE_ID
        WHERE
                aau.availability_scope_type = 'A'       
        UNION ALL
        SELECT 
                aau.*,
                aau.availability_scope_id AS center_id 
        FROM activity_availability_unnested aau
        WHERE
                aau.availability_scope_type = 'C'
        ),
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
                        activity_group_id,
                        max_participants,
                        colour_group_id,
                        duration_list  
                FROM
                (  
                select 
                *,
                rank() over (partition BY coalesce(a.top_node_id, a.id), sc."CENTER_ID" ORDER BY sc."LEVEL" DESC) AS rnk
                from 
                evolutionwellness.activity a
                join scope_center sc
                ON 
                a.scope_type = sc."SCOPE_TYPE"
                AND a.scope_id = sc."SCOPE_ID"
                WHERE  
                  a.state = 'ACTIVE'
                ) 
                WHERE
                  rnk = 1
                  AND "CENTER_ID" IN (200,203,204,209,211,214,215,217,218,219,220)  
                )                        
SELECT DISTINCT
        c.id AS "Center ID"
		,c.name AS "Center Name"
        ,a.name AS "Activity Name"
        ,CASE
                WHEN override.max_participants IS NOT NULL THEN override.max_participants
                ELSE a.max_participants 
        END AS "Maximum Participants"
        ,a.max_waiting_list_participants AS "Maximum waiting list Participants"
        ,ag.name AS "Activity Group"
        ,CASE
                WHEN ocg.name IS NOT NULL THEN ocg.name
                ELSE cg.name 
        END AS "Color"
        ,brg.name AS "Activity Resource Group"
        ,CASE
                WHEN override.duration_list IS NOT NULL THEN override.duration_list
                ELSE a.duration_list 
        END AS "Activity Duration" 
        ,arg.name AS "Resource Type" 
        ,brgn.name AS "Resource Group Name" 
        ,br.name AS "Resource Name"
FROM
        evolutionwellness.activity a
JOIN
        evolutionwellness.colour_groups cg
        ON cg.id = a.colour_group_id 
JOIN
        evolutionwellness.activity_group ag
        ON a.activity_group_id = ag.id
JOIN
        evolutionwellness.activity_resource_configs arc
        ON a.id = arc.activity_id  
JOIN
        evolutionwellness.booking_resource_groups brg
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
        evolutionwellness.booking_time_configs btc
        ON btc.id = override.time_config_id
        AND override.top_node_id IS NOT NULL
LEFT JOIN
        evolutionwellness.booking_time_configs btca
        ON btca.id = a.time_config_id
        AND override.top_node_id IS NULL
JOIN
        availability 
        ON availability.id = a.id
        AND availability.center_id = c.id 
LEFT JOIN
        evolutionwellness.colour_groups ocg
        ON override.colour_group_id = ocg.id
LEFT JOIN
        evolutionwellness.activity_resource_configs arg
        ON arg.activity_id = a.id 
LEFT JOIN
        evolutionwellness.booking_resource_groups brgn
        ON brgn.id = arg.booking_resource_group_id
LEFT JOIN
        evolutionwellness.booking_resource_configs brc
        ON brgn.id = brc.group_id
        AND brc.booking_resource_center = c.id
LEFT JOIN
        evolutionwellness.booking_resources br
        ON br.id = brc.booking_resource_id
        AND br.center = brc.booking_resource_center        
WHERE 
        c.id IN (200,203,204,209,211,214,215,217,218,219,220)
        AND
        a.state = 'ACTIVE'