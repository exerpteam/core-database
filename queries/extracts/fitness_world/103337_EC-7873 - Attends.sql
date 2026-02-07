-- This is the version from 2026-02-05
--  
SELECT
att.center AS "Center",
TO_CHAR(longtodateC(att.start_time, att.center), 'dd-MM-YYYY HH24:MI') AS "Tidspunkt",
att.person_center AS "Medlem Center",
att.person_id::varchar(20) AS "Medlem ID",
TO_CHAR(longtodateC(att.last_modified, att.center), 'dd-MM-YYYY HH24:MI') AS "Senest justeret"
FROM
attends att
WHERE
att.person_center ||'p'|| att.person_id IN (:memberid)
ORDER BY
att.start_time