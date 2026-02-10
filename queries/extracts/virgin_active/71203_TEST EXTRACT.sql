-- The extract is extracted from Exerp on 2026-02-08
--  
 SELECT
        e.ID "Report ID",
     e.NAME,
        eg.name "Folder",
 e.description,
    longToDate(MAX(eu.TIME)) last_used,
     COUNT(e.ID)
 FROM
     EXTRACT_USAGE eu
 JOIN
        EXTRACT e
        ON e.ID = eu.EXTRACT_ID
        AND e.SCOPE_ID = 24 
 JOIN
     EXTRACT_GROUP_LINK egl
        ON egl.EXTRACT_ID = e.ID
 JOIN
     EXTRACT_GROUP eg
        ON egl.GROUP_ID = eg.ID
 WHERE
     e.BLOCKED = 0
 GROUP BY
        e.ID,
     e.NAME,
 e.description,
 eg.name
 ORDER BY
        e.Name asc,
        eg.name asc,
     COUNT(e.ID) ASC
