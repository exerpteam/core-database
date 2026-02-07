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
 JOIN
     EXTRACT_GROUP_LINK egl
        ON egl.EXTRACT_ID = e.ID
 JOIN
     EXTRACT_GROUP eg
        ON egl.GROUP_ID = eg.ID
 WHERE
     e.BLOCKED = 0
AND	
	e.scope_id <> '24'
AND
	eg.name NOT LIKE ('%Italy%') 
AND 
	eg.name NOT LIKE ('%Gamma%')
AND
	e.NAME NOT LIKE ('%GAMMA%')
 GROUP BY
        e.ID,
     e.NAME,
 e.description,
 eg.name
 ORDER BY
        e.Name asc,
        eg.name asc,
     COUNT(e.ID) ASC
