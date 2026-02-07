-- This is the version from 2026-02-05
--  
SELECT
    p.center,
    p.id,
    p.firstname || ' ' || p.lastname              AS MemberName,
    p.ssn,
to_char(longtodate(c.start_time),'DD-MM-YYYY HH24:MI') as checkintime, 
  longtodate(c.start_time)       AS Checkin_times
FROM
    fw.persons p
LEFT JOIN attends c
ON
    p.center = c.person_CENTER
AND p.id=c.person_id
WHERE
     c.start_time BETWEEN
:time_from 
    and (:time_to + 86400000)
and (p.CENTER,p.ID) IN (:members)
group by
    p.center,
    p.id,
    p.firstname || ' ' || p.lastname,
    p.ssn,
    c.start_time
ORDER BY
    p.center,
    p.id,
    c.start_time