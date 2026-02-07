WITH
    PARAMS AS
    (
        SELECT
            datetolongTZ(TO_CHAR(SYSDATE- :Days_back, 'YYYY-MM-dd HH24:MI'),'Europe/Berlin') AS FROMDATE,
            datetolongTZ(TO_CHAR(SYSDATE, 'YYYY-MM-dd HH24:MI'),'Europe/Berlin') AS TODATE
        FROM
	    dual
    )
SELECT 
  list_groups.Fullname AS "Employee Name",
  list_groups.center||'p'||list_groups.id AS "Employee id",
  list_groups.StaffGroups  AS "Staff group(s)",
  ROUND((params.TODATE - last_booked.LastTime) / (24*3600000)) AS "Number of days back",
  c.SHORTNAME  As "Club",
  UTL_I18N.RAW_TO_CHAR(DBMS_LOB.SUBSTR(je.big_text, 4000,1), 'UTF8') AS "Note"
FROM
PARAMS, 
(    
SELECT 
    p.center AS StaffPersonCenter,
    p.id AS StaffPersonId
FROM
    persons p
JOIN
    EMPLOYEES e
ON
    p.CENTER = e.PERSONCENTER
    AND p.ID = e.PERSONID
WHERE
    p.center in (:center)   
    AND e.USE_API = 1
    AND e.BLOCKED = 0
    AND (e.PASSWD_EXPIRATION IS NULL OR e.PASSWD_EXPIRATION >= SYSDATE)

MINUS
        
SELECT
    su.person_center AS StaffPersonCenter,
    su.person_id AS StaffPersonId
FROM
    bookings b
CROSS JOIN
    params
JOIN
    activity ac
ON
    b.activity = ac.id
    AND ac.activity_type = 4 
JOIN
    participations par
ON
    b.center = par.booking_center
    AND b.id = par.booking_id
    AND par.STATE <> 'CANCELLED'
JOIN
    staff_usage su
ON 
    su.booking_center = b.center
    AND su.booking_id = b.id
WHERE
    b.starttime >= params.fromdate
    AND b.starttime < params.todate
    AND su.person_center in (:center)
) 
  not_booked_staff
JOIN
(
   SELECT 
      p.FULLNAME, 
      p.CENTER,
      p.id,
      listagg(sg.NAME, ',') within group (order by sg.NAME) AS StaffGroups
   FROM 
      persons p
   JOIN
      person_staff_groups ps   
   ON 
      ps.person_center = p.center
      AND ps.person_id = p.id
   JOIN
      STAFF_GROUPS sg
   ON
      sg.ID = ps.STAFF_GROUP_ID
   WHERE 
--      p.PERSONTYPE = 2
      --AND
       ps.scope_id in (:center)
      AND ps.scope_type ='C'
   GROUP BY
      p.center, p.id, p.FULLNAME
)
   list_groups
ON
   list_groups.CENTER = not_booked_staff.StaffPersonCenter
   AND list_groups.ID = not_booked_staff.StaffPersonId
JOIN
   centers c
ON
   c.ID = not_booked_staff.StaffPersonCenter
LEFT JOIN
(
SELECT
    su.person_center,
    su.person_id,
    MAX(b.StartTime) AS LastTime 
FROM
    PARAMS,
    bookings b
JOIN
    activity ac
ON
    b.activity = ac.id
    AND ac.activity_type = 4 
JOIN
    participations par
ON
    b.center = par.booking_center
    AND b.id = par.booking_id
    AND par.STATE <> 'CANCELLED'
JOIN
    staff_usage su
ON 
    su.booking_center = b.center
    AND su.booking_id = b.id
WHERE
    su.person_center in (:center)
    AND b.starttime < params.todate
GROUP BY
    su.person_center, su.person_id
) 
  last_booked
ON
    last_booked.person_center = not_booked_staff.StaffPersonCenter
    AND last_booked.person_id = not_booked_staff.StaffPersonId
LEFT JOIN
   JOURNALENTRIES je
ON
   not_booked_staff.StaffPersonCenter = je.PERSON_CENTER
   AND not_booked_staff.StaffPersonId = je.PERSON_ID
   AND je.JETYPE = 3
   AND UPPER(TRIM(je.name)) = 'GDPR NOTE'
