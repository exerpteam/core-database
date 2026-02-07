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