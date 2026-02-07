SELECT
    biview.*
FROM
    (SELECT
    CAST ( a.ID AS VARCHAR(255))     AS "AREA_ID",
    CAST ( a.PARENT AS VARCHAR(255)) AS "PARENT",
    a.NAME                           AS "AREA_NAME",
    tree.name                        AS "TREE_NAME" ,
    CASE
        WHEN a.BLOCKED = 1
        THEN 'TRUE'
        ELSE 'FALSE'
    END AS "BLOCKED"
FROM
    AREAS a
LEFT JOIN
    (
        SELECT
            parent   AS id,
            COUNT(*) AS children_count
        FROM
            AREAS
        WHERE
            blocked=0
        GROUP BY
            parent) parents
ON
    parents.id = a.parent
JOIN
    AREAS tree
ON
    tree.id = a.ROOT_AREA
WHERE
    a.BLOCKED = 0
    ) biview