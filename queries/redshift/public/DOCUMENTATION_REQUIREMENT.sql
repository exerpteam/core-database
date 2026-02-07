WITH
    doc_setting AS
    (
        SELECT
            DOCUMENTATION_SETTING_ID AS "DOCUMENTATION_SETTING_ID",
            center_id,
            first_value(name) over (partition BY center_id, DOCUMENTATION_SETTING_ID ORDER BY name
            IS NOT NULL DESC , rnk ASC) AS "NAME",
            first_value(external_id) over (partition BY center_id, DOCUMENTATION_SETTING_ID
            ORDER BY external_id IS NOT NULL DESC, rnk ASC) AS "EXTERNAL_ID",
            first_value(documentation_setting_type) over (partition BY center_id,
            DOCUMENTATION_SETTING_ID ORDER BY documentation_setting_type IS NOT NULL DESC, rnk ASC)
            AS documentation_setting_type,
            rnk
        FROM
            (
                SELECT
                    *,
                    rank() over (partition BY DOCUMENTATION_SETTING_ID, center_id ORDER BY ranking
                    desc) AS rnk
                FROM
                    (
                        SELECT
                            ds.ID             AS ID,
                            ds.definition_key AS DOCUMENTATION_SETTING_ID,
                            ds.name           AS NAME,
                            ds.external_id    AS EXTERNAL_ID,
                            CASE
                                WHEN ds.scope_type = 'C' -- override on center
                                THEN ds.scope_id
                                ELSE
                                    CASE
                                        WHEN c.id IS NOT NULL -- override on tree
                                        THEN c.ID
                                        ELSE ac.center
                                    END
                            END AS CENTER_ID,
                            CASE
                                WHEN ds.scope_type = 'C' -- override on center
                                THEN 999
                                WHEN ds.scope_type = 'A' -- override on center
                                THEN areas_total.level
                                WHEN ds.scope_type IN('G',
                                                      'T')
                                THEN 0
                            END                     AS ranking,
                            ds.override_name        AS OVERRIDE_NAME,
                            ds.override_external_id AS OVERRIDE_EXTERNAL_ID,
                            ds.type                 AS DOCUMENTATION_SETTING_TYPE
                        FROM
                            documentation_settings ds
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
                                            array_append(cin.chain_of_command_ids, a.id) AS
                                                             chain_of_command_ids,
                                            cin.level + 1 AS level
                                        FROM
                                            areas a
                                        JOIN
                                            centers_in_area cin
                                        ON
                                            cin.id = a.parent
                                    )
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
                                    1,2) areas_total
                        ON
                            areas_total.id = ds.scope_id
                        AND ds.scope_type = 'A'
                        LEFT JOIN
                            area_centers ac
                        ON
                            ac.area = areas_total.sub_areas
                        JOIN
                            centers c
                        ON
                            ds.scope_type IN ('T',
                                              'G')
                        OR  (
                                ds.scope_type = 'C'
                            AND ds.scope_id = c.id)
                        OR  (
                                ds.scope_type = 'A'
                            AND ac.CENTER = c.id)
                        WHERE
                            ds.state NOT IN('DELETED',
                                            'INACTIVE')
                        OR  ds.state IS NULL ) t ) t
    )
SELECT
    dr.ID                         AS "ID",
    dr.documentation_setting_type AS "SOURCE_TYPE",
    CASE
        WHEN ds.documentation_setting_type = 'SUBSCRIPTION'
        THEN dr.source_center||'ss'||dr.source_id
        WHEN ds.documentation_setting_type = 'BOOKING_PROGRAM'
        THEN dr.source_key||''
        WHEN ds.documentation_setting_type = 'CLIPCARD'
        THEN dr.source_center||'cc'||dr.source_id || 'cc' ||dr.source_sub_id
        WHEN ds.documentation_setting_type = 'SUBSCRIPTION_ADDON'
        THEN dr.source_key||''
        WHEN ds.documentation_setting_type = 'ACTIVITY'
        THEN dr.source_key||''
    END AS "SOURCE_ID",
    CASE
        WHEN (p.CENTER != p.TRANSFERS_CURRENT_PRS_CENTER
            OR  p.id != p.TRANSFERS_CURRENT_PRS_ID )
        THEN
            (
                SELECT
                    EXTERNAL_ID
                FROM
                    PERSONS
                WHERE
                    CENTER = p.TRANSFERS_CURRENT_PRS_CENTER
                AND ID = p.TRANSFERS_CURRENT_PRS_ID)
        ELSE p.EXTERNAL_ID
    END                          AS "PERSON_ID",
    dr.state                     AS "STATE",
    dr.is_needed                 AS "REQUIRED",
    dr.documentation_setting_key AS "SETTING_KEY",
    ds."NAME"                    AS "SETTING_NAME",
    dr.creation_time             AS "CREATION_DATETIME",
    dr.completion_time           AS "COMPLETION_DATETIME",
    ds.CENTER_ID                 AS "CENTER_ID",
    ds."EXTERNAL_ID",
    dr.last_modified AS "ETS"
FROM
    documentation_requirements dr
LEFT JOIN
    booking_programs bp
ON
    bp.id = dr.source_key
AND dr.documentation_setting_type = 'BOOKING_PROGRAM'
JOIN
    doc_setting ds
ON
    ds."DOCUMENTATION_SETTING_ID" = dr.documentation_setting_key
AND ds.CENTER_ID = COALESCE(bp.center,dr.source_owner_center)
AND ds.rnk = 1
LEFT JOIN
    persons p
ON
    dr.source_owner_center = p.center
AND dr.source_owner_id = p.id
