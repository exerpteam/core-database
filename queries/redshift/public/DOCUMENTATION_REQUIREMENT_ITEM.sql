WITH
    custom_journal_document AS
    (
        SELECT
            ID,
            custom_journal_document_types_key,
            center_id,
            first_value(name) over (partition BY custom_journal_document_types_key, center_id
            ORDER BY name IS NOT NULL DESC , rnk ASC) AS name,
            first_value(external_id) over (partition BY custom_journal_document_types_key,
            center_id ORDER BY external_id IS NOT NULL DESC , rnk ASC) AS external_id,
            rnk,
            ranking
        FROM
            (
                SELECT
                    *,
                    rank() over (partition BY custom_journal_document_types_key, center_id ORDER BY
                    ranking DESC) AS rnk
                FROM
                    (
                        SELECT
                            cj.ID             AS ID,
                            cj.definition_key AS custom_journal_document_types_key,
                            cj.name           AS NAME,
                            cj.external_id    AS EXTERNAL_ID,
                            CASE
                                WHEN cj.scope_type = 'C' -- override on center
                                THEN cj.scope_id
                                ELSE
                                    CASE
                                        WHEN c.id IS NOT NULL -- override on tree
                                        THEN c.ID
                                        ELSE ac.center
                                    END
                            END AS CENTER_ID,
                            CASE
                                WHEN cj.scope_type = 'C' -- override on center
                                THEN 999
                                WHEN cj.scope_type = 'A' -- override on center
                                THEN areas_total.level
                                WHEN cj.scope_type IN('G',
                                                      'T')
                                THEN 0
                            END                     AS ranking,
                            cj.override_name        AS OVERRIDE_NAME,
                            cj.override_external_id AS OVERRIDE_EXTERNAL_ID
                        FROM
                            custom_journal_document_types cj
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
                            areas_total.id = cj.scope_id
                        AND cj.scope_type = 'A'
                        LEFT JOIN
                            area_centers ac
                        ON
                            ac.area = areas_total.sub_areas
                        JOIN
                            centers c
                        ON
                            cj.scope_type IN ('T',
                                              'G')
                        OR  ( cj.scope_type = 'C'
                            AND cj.scope_id = c.id)
                        OR  ( cj.scope_type = 'A'
                            AND ac.CENTER = c.id)
                        WHERE
                            cj.state NOT IN('DELETED',
                                            'INACTIVE')
                        OR  cj.state IS NULL ) t ) t
    )
SELECT DISTINCT
    i.ID                            AS "ID",
    i.DOCUMENTATION_REQUIREMENT_KEY AS "DOCUMENTATION_REQUIREMENT_ID",
    i.name                          AS "NAME",
    i.type                          AS "TYPE",
    i.STATE                         AS "STATE",
    CASE
        WHEN i.type IN ('CUSTOM_JOURNAL_DOCUMENT',
                        'CONTRACT')
        THEN 'DOCUMENT'
        WHEN i.type = 'QUESTIONNAIRE'
        THEN 'ANSWER_SUBMISSION'
    END AS "TARGET_TYPE",
    CASE
        WHEN i.type IN ('CUSTOM_JOURNAL_DOCUMENT',
                        'CONTRACT')
        THEN i.itm_instance_journal_entry_key||''
        WHEN i.type = 'QUESTIONNAIRE'
        THEN i.item_instance_center||'p'||i.item_instance_id||'qa'||i.item_instance_sub_id
    END                    AS "TARGET_ID",
    dr.source_owner_center AS "CENTER_ID",
    cjd.EXTERNAL_ID        AS "EXTERNAL_ID",
	dr.last_modified       AS "ETS"
FROM
    DOC_REQUIREMENT_ITEMS i
JOIN
    DOCUMENTATION_REQUIREMENTS dr
ON
    i.DOCUMENTATION_REQUIREMENT_KEY = dr.ID
LEFT JOIN
    custom_journal_document cjd
ON
    cjd.custom_journal_document_types_key = i.item_type_key
AND i.type = 'CUSTOM_JOURNAL_DOCUMENT'
AND cjd.CENTER_ID = dr.source_owner_center
AND rnk = 1
