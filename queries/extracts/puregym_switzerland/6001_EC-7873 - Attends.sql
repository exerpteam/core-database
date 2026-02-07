SELECT
        att.center AS "Center",
        TO_CHAR(longtodateC(att.start_time, att.center), 'dd-MM-YYYY HH24:MI') AS "Point in time",
        att.person_center AS "Member Center",
        CAST(att.person_id AS TEXT) AS "Member ID",
        TO_CHAR(longtodateC(att.last_modified, att.center), 'dd-MM-YYYY HH24:MI') AS "Last adjusted"
FROM attends att
WHERE
        (att.person_center,att.person_id) IN (:memberid)
ORDER BY
        att.start_time