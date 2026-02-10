-- The extract is extracted from Exerp on 2026-02-08
--  
-- All PT attends (drop in & bookings)
SELECT
	a.CENTER,
	c1.SHORTNAME AS CenterName,
	a.PERSON_CENTER || 'p' || a.PERSON_ID AS PersonId,
	longToDate(a.START_TIME) AS Dato,
	--br.NAME AS AttendType,
	1 AS DropIn,
	NULL AS Booked
FROM
	ATTENDS a
LEFT JOIN BOOKING_RESOURCES br
ON
	a.BOOKING_RESOURCE_CENTER = br.CENTER
	AND a.BOOKING_RESOURCE_ID = br.ID
LEFT JOIN CENTERS c1
ON
	a.CENTER = c1.ID
WHERE
	a.CENTER IN (:Scope)
	AND a.STATE LIKE 'ACTIVE'
	AND br.ATTEND_PRIVILEGE_ID = 1001 --PT
	AND a.START_TIME >= :FromDate
    AND a.START_TIME < :ToDate + 3600*1000*24
	
UNION ALL

SELECT
	b.CENTER,
	c2.SHORTNAME AS CenterName,
	b.OWNER_CENTER || 'p' || b.OWNER_ID AS PersonID,
	longToDate(b.STARTTIME) AS Dato,
	--b.NAME AS AttendType,
	NULL AS DropIn,
	1 AS Booked
FROM BOOKINGS b
LEFT JOIN CENTERS c2
ON
	b.CENTER = c2.ID
WHERE
	b.CENTER IN (:Scope)
	AND b.STATE LIKE 'ACTIVE'
	AND b.ACTIVITY IN (3008, 4807) -- se and no bookings
	AND b.NAME LIKE 'Personlig Träning'
	AND b.STARTTIME >= :FromDate
    AND b.STARTTIME < :ToDate + 3600*1000*24

ORDER BY Dato
