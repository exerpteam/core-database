-- This is the version from 2026-02-05
--  
SELECT
CAST ( ac.center AS VARCHAR(255)) AS "CENTER_ID",
    CAST ( a.ID AS VARCHAR(255))      AS "AREA_ID",
    root_area.name                    AS "TREE_NAME"
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
