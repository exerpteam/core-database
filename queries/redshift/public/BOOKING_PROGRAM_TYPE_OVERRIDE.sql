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
            a.types LIKE '%system%' AND a.parent IS NULL
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
            cin.id = ANY (b.chain_of_command_ids) AND cin.level <= b.level
        GROUP BY
            1,2
    )
SELECT
    "ID",
    "BOOKING_PROGRAM_TYPE_ID",
    "NAME",
    "DESCRIPTION",
    "TIME_CONFIGURATION_ID",
    "AGE_GROUP_ID",
    "CENTER_ID"
FROM
    (
        SELECT
            "ID",
            "BOOKING_PROGRAM_TYPE_ID",
            COALESCE("NAME", lag("NAME") over(partition BY "BOOKING_PROGRAM_TYPE_ID","CENTER_ID" ORDER BY name_partition, ranking DESC rows BETWEEN unbounded preceding AND CURRENT row), def_bpt.name
            )                   AS "NAME",
            def_bpt.description AS "DESCRIPTION",
            def_bpt.time_config_id "TIME_CONFIGURATION_ID",
            COALESCE("AGE_GROUP_ID", lag("AGE_GROUP_ID") over(partition BY "BOOKING_PROGRAM_TYPE_ID","CENTER_ID" ORDER BY ag_partition, ranking DESC rows BETWEEN unbounded preceding AND CURRENT row),
            CASE
                WHEN def_bpt.age_group_id = -1
                THEN NULL
                ELSE def_bpt.age_group_id
            END) AS "AGE_GROUP_ID",
            "CENTER_ID",
            rank() over (partition BY "BOOKING_PROGRAM_TYPE_ID", "CENTER_ID" ORDER BY ranking DESC) AS rnk
        FROM
            (
                SELECT
                    * ,
                    SUM(
                        CASE
                            WHEN "NAME" IS NULL
                            THEN 0
                            ELSE 1
                        END) over (ORDER BY ranking ) AS name_partition,
                    SUM(
                        CASE
                            WHEN "AGE_GROUP_ID" IS NULL
                            THEN 0
                            ELSE 1
                        END) over (ORDER BY ranking ) AS ag_partition
                FROM
                    (
                        SELECT
                            bpt.ID             AS "ID",
                            bpt.definition_key AS "BOOKING_PROGRAM_TYPE_ID",
                            bpt.name           AS "NAME",
                            CASE
                                WHEN bpt.age_group_id = -1
                                THEN NULL
                                ELSE bpt.age_group_id
                            END AS "AGE_GROUP_ID",
                            CASE
                                WHEN bpt.scope_type = 'C' -- override on center
                                THEN bpt.scope_id
                                ELSE
                                    CASE
                                        WHEN c.id IS NOT NULL -- override on tree
                                        THEN c.ID
                                        ELSE ac.center
                                    END
                            END AS "CENTER_ID",
                            CASE
                                WHEN bpt.scope_type = 'C' -- override on center
                                THEN 999
                                WHEN bpt.scope_type = 'A' -- override on center
                                THEN areas_total.level
                                WHEN bpt.scope_type IN('G',
                                                       'T')
                                THEN 0
                            END AS ranking
                        FROM
                            booking_program_types bpt
                        LEFT JOIN
                            areas_total
                        ON
                            areas_total.id = bpt.scope_id AND bpt.scope_type = 'A'
                        LEFT JOIN
                            area_centers ac
                        ON
                            ac.area = areas_total.sub_areas
                        JOIN
                            centers c
                        ON
                            bpt.scope_type IN ('T',
                                               'G') OR (
                                bpt.scope_type = 'C' AND bpt.scope_id = c.id) OR (
                                bpt.scope_type = 'A' AND ac.CENTER = c.id) ) t)t
        JOIN
            booking_program_types def_bpt
        ON
            def_bpt.id = t."BOOKING_PROGRAM_TYPE_ID")t
WHERE
    rnk = 1