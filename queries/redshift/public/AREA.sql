SELECT
    a.ID                                      AS "ID",
    a.PARENT                                  AS "PARENT_AREA_ID",
    a.NAME                                    AS "NAME",
    tree.name                                 AS "TREE_NAME" ,
    CAST(CAST (a.BLOCKED AS INT) AS SMALLINT) AS "BLOCKED",
    a.types SIMILAR TO 'bi,%|%,bi,%|%,bi|bi'  AS "BI_TREE"
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