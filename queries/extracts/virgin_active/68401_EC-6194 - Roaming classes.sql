-- The extract is extracted from Exerp on 2026-02-08
--  
SELECT
c.ID "Center Id",
c.NAME "Center Name",
bo.NAME "Class Name",
ag.name "Activity Group",
TO_CHAR(longtodate(bo.starttime), 'dd-MM-YYYY HH24:MI') "Class Start",
TO_CHAR(longtodate(bo.stoptime), 'dd-MM-YYYY HH24:MI') "Class End",
br.NAME AS "Class location",
SUM(
                 CASE
                     WHEN par.participant_center = par.booking_center
                     THEN 1
                     ELSE 0
                 END )AS "Participants home club",
SUM(
                 CASE
                     WHEN par.participant_center != par.booking_center
                     THEN 1
                     ELSE 0
                 END )AS "Participants not home club"
FROM
bookings bo
JOIN
centers c
ON
c.ID = bo.center
JOIN
participations par
ON
par.booking_center = bo.center
AND par.booking_id = bo.id
AND par.state = 'PARTICIPATION'
JOIN activity a
ON
a.id = bo.activity
JOIN activity_group ag
ON
ag.id = a.activity_group_id
JOIN
    BOOKING_RESOURCE_USAGE bru
ON
    bo.ID = bru.BOOKING_ID
AND bo.CENTER = bru.BOOKING_CENTER
AND bru.STATE != 'CANCELLED'
JOIN
    BOOKING_RESOURCES br
ON
    br.CENTER = bru.BOOKING_RESOURCE_CENTER
AND br.ID = bru.BOOKING_RESOURCE_ID
WHERE
bo.state = 'ACTIVE'
AND c.id in (:scope)
AND bo.starttime BETWEEN :from_date AND :to_date
GROUP BY
c.ID,
c.NAME,
bo.NAME,
ag.name,
br.NAME,
bo.starttime,
bo.stoptime
ORDER BY
c.ID,
bo.starttime,
bo.stoptime