SELECT DISTINCT ON
    ("PERSON_ID", "STAFF_GROUP_ID","CENTER_ID")
        "PERSON_ID",
    "STAFF_GROUP_ID",
    "CENTER_ID",
    "SALARY"
FROM
    (
        SELECT
    p.EXTERNAL_ID      AS "PERSON_ID",
    psg.staff_group_id AS "STAFF_GROUP_ID",
    CASE
        WHEN psg.scope_type = 'C' -- override on center
        THEN psg.scope_id
        ELSE
            CASE
                WHEN c.id IS NOT NULL -- override on tree
                THEN c.ID
                ELSE ac.center
            END
    END AS "CENTER_ID",
    cast(psg.salary as numeric(1000,2)) AS "SALARY" ,
    ---using levels from the recursive clause and assigning here null for center overrides to find lowest scope in next query
    CASE psg.scope_type
        WHEN 'C'
        THEN null
        else
        coalesce(Scope_Level, 0)
    END AS Override_Level 
FROM
    person_staff_groups psg
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
            cin.level                                   as Scope_Level,
            unnest(array_remove(array_agg(b.ID), NULL)) AS sub_areas
        FROM
            centers_in_area cin
        LEFT JOIN
            centers_in_area AS b -- join provides subordinates
        ON
            cin.id = ANY (b.chain_of_command_ids)
        AND cin.level <= b.level
        GROUP BY
            cin.id,
            cin.level ) areas_total
ON
    areas_total.id = psg.scope_id
AND psg.scope_type = 'A'
LEFT JOIN
    area_centers ac
ON
    ac.area = areas_total.sub_areas
JOIN
    centers c
ON
    psg.scope_type IN ('T',
                       'G')
OR  (
        psg.scope_type = 'C'
    AND psg.scope_id = c.id)
OR  (
        psg.scope_type = 'A'
    AND ac.CENTER = c.id)
JOIN
    persons p
ON
    p.center = psg.person_center
AND p.id = psg.person_id
AND p.external_id is not null
    ) t
order by
    "PERSON_ID",
    "STAFF_GROUP_ID",
    "CENTER_ID",
    Override_Level DESC