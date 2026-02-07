SELECT
    ac.center      AS "CENTER_ID",
    a.ID           AS "AREA_ID",
    root_area.name AS "TREE_NAME"
FROM
    AREA_CENTERS ac
JOIN
    AREAS a
ON
    a.id = ac.AREA
JOIN
    AREAS root_area
ON
    root_area.ID=a.ROOT_AREA
JOIN
    centers c
ON
    c.id = ac.center