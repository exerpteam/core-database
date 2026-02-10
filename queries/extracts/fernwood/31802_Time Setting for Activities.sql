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
                FROM activity a
                LEFT JOIN activity topact ON a.top_node_id = topact.id
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
        active_in_center AS
        (
        SELECT DISTINCT                
                b.center
                ,a.id
        FROM    
                activity a
        JOIN
                bookings b
                ON b.activity = a.id        
        WHERE 
                b.starttime > datetolong(to_char(current_date, 'YYYY-MM-DD'))
                AND 
                b.state = 'ACTIVE' 
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
                        max_participants  
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
                  AND "CENTER_ID" IN (:Scope)  
                )                        
SELECT DISTINCT
        c.name AS "Club"
        ,a.name AS "Activity Name"
        ,CASE
                WHEN btc.name IS NOT NULL THEN btc.part_start_value ||' '||
                                                                CASE
                                                                        WHEN btc.part_start_unit = 0 THEN 'Week'
                                                                        WHEN btc.part_start_unit = 1 THEN 'Day'
                                                                        WHEN btc.part_start_unit = 2 THEN 'Month'
                                                                        WHEN btc.part_start_unit = 3 THEN 'Year'
                                                                        WHEN btc.part_start_unit = 4 THEN 'Hour'
                                                                        WHEN btc.part_start_unit = 5 THEN 'Minute'
                                                                        ELSE ''
                                                                END
                ||' '||btc.part_start_round
                ELSE  btca.part_start_value ||' '||
                                                                CASE
                                                                        WHEN btca.part_start_unit = 0 THEN 'Week'
                                                                        WHEN btca.part_start_unit = 1 THEN 'Day'
                                                                        WHEN btca.part_start_unit = 2 THEN 'Month'
                                                                        WHEN btca.part_start_unit = 3 THEN 'Year'
                                                                        WHEN btca.part_start_unit = 4 THEN 'Hour'
                                                                        WHEN btca.part_start_unit = 5 THEN 'Minute'
                                                                        ELSE ''
                                                                END
                ||' '||btca.part_start_round
        END AS "Booking From"
        ,CASE
                WHEN btc.name IS NOT NULL THEN btc.part_cancel_stop_cus_value ||' '||
                                                                CASE
                                                                        WHEN btc.part_cancel_stop_cus_unit = 0 THEN 'Week'
                                                                        WHEN btc.part_cancel_stop_cus_unit = 1 THEN 'Day'
                                                                        WHEN btc.part_cancel_stop_cus_unit = 2 THEN 'Month'
                                                                        WHEN btc.part_cancel_stop_cus_unit = 3 THEN 'Year'
                                                                        WHEN btc.part_cancel_stop_cus_unit = 4 THEN 'Hour'
                                                                        WHEN btc.part_cancel_stop_cus_unit = 5 THEN 'Minute'
                                                                        ELSE ''
                                                                END
                ELSE  btca.part_cancel_stop_cus_value ||' '||
                                                                CASE
                                                                        WHEN btca.part_cancel_stop_cus_unit = 0 THEN 'Week'
                                                                        WHEN btca.part_cancel_stop_cus_unit = 1 THEN 'Day'
                                                                        WHEN btca.part_cancel_stop_cus_unit = 2 THEN 'Month'
                                                                        WHEN btca.part_cancel_stop_cus_unit = 3 THEN 'Year'
                                                                        WHEN btca.part_cancel_stop_cus_unit = 4 THEN 'Hour'
                                                                        WHEN btca.part_cancel_stop_cus_unit = 5 THEN 'Minute'
                                                                        ELSE ''
                                                                END
        END AS "Cancellation Window"
        ,CASE
                WHEN override.max_participants IS NOT NULL THEN override.max_participants
                ELSE a.max_participants 
        END AS "Maximum Participants"
        ,a.max_waiting_list_participants AS "Maximum waiting list Participants"
        ,ag.name AS "Activity Group"
        ,cg.name AS "Color"
        ,brg.name AS "Resource Group"
        ,a.duration_list AS "Duration"
        ,CASE WHEN 
                btc.name IS NOT NULL THEN btc.name
                ELSE btca.name
        END AS "Time Settings (Internal Use)"
        ,CASE aic.center
                WHEN NULL THEN 'No'
                ELSE 'Yes'
        END AS "used in planning"           
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
        booking_time_configs btc
        ON btc.id = override.time_config_id
        AND override.top_node_id IS NOT NULL
LEFT JOIN
        booking_time_configs btca
        ON btca.id = a.time_config_id
        AND override.top_node_id IS NULL
LEFT JOIN       
        active_in_center aic
        ON aic.id = override.top_node_id    
JOIN
        availability 
        ON availability.id = a.id
        AND availability.center_id = c.id                                                                                     
WHERE 
        ag.id IN (:ActivityGroup)
        AND
        c.id IN (:Scope)
        AND
        a.state = 'ACTIVE'
                                  