SELECT
    a.ID AS "ID",
    CASE
        WHEN a.TOP_NODE_ID IS NOT NULL
        THEN a.TOP_NODE_ID
        ELSE a.id
    END              AS "ACTIVITY_ID",    
    a.name           AS "NAME",
    a.time_config_id AS "TIME_CONFIGURATION_ID",
    CASE 
		WHEN a.age_group_id = -1
		THEN null
		ELSE a.age_group_id
	END            	 AS "AGE_GROUP_ID",
    CASE
        WHEN a.scope_type = 'C' -- override on center
        THEN a.scope_id
        ELSE
            CASE
                WHEN c.id IS NOT NULL -- override on tree
                THEN c.ID
                ELSE ac.center
            END
    END AS "CENTER_ID",
    asco.staff_group_id                 AS "STAFF_GROUP_ID",
    a.max_participants                  AS "MAX_PARTICIPANTS",
    a.max_waiting_list_participants     AS "MAX_WAITING_LIST_PARTICIPANTS"
FROM
    activity a
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
        ON
            cin.id = ANY (b.chain_of_command_ids)
        AND cin.level <= b.level
        GROUP BY
            1) areas_total
ON
    areas_total.id = a.scope_id
AND a.scope_type = 'A'
LEFT JOIN
    area_centers ac
ON
    ac.area = areas_total.sub_areas
LEFT JOIN   
    activity_staff_configurations asco
ON 
    asco.activity_id = a.id  
JOIN
    centers c
ON
    a.scope_type IN ('T',
                     'G')
OR  (
        a.scope_type = 'C'
    AND a.scope_id = c.id)
OR  (
        a.scope_type = 'A'
    AND ac.CENTER = c.id)
WHERE
    a.STATE != 'DRAFT'