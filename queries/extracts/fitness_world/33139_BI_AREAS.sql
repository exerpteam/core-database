-- This is the version from 2026-02-05
--  
SELECT
    a.ID      AS "AREA_ID",
    a.PARENT  AS "PARENT",
    a.NAME    AS "AREA_NAME",
    tree.name AS "TREE_NAME",
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
    AND (
        parents.children_count <> 1
        OR NOT (
            a.parent = a.ROOT_AREA))
