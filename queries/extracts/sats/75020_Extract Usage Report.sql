 SELECT
     e.id Extract_ID,
     e.name Extract_Name,
     to_char(longtodateC(max(eu.time),100),'YYYY-MM-DD HH24:MI') Last_Used_Time,
     CASE WHEN e.BLOCKED = 1 THEN 'BLOCKED' ELSE 'ACTIVE' END STATUS
 FROM
     extract e
 LEFT JOIN
     EXTRACT_USAGE EU
 ON
     e.id = eu.extract_id
 GROUP by
    e.id, e.name, e.blocked
 ORDER BY 1
