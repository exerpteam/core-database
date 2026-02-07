/* QV2PTUsageDaily */
/*
 * All PT attends (drop in & bookings)
 */
-- TODO
WITH
    PARAMS AS
    (
        SELECT
                /*+ materialize */
				datetolongTZ(TO_CHAR(TRUNC(to_date(getcentertime(c.id), 'YYYY-MM-DD HH24:MI')-1), 'YYYY-MM-DD HH24:MI'),co.DEFAULTTIMEZONE) AS fromDate,
                datetolongTZ(TO_CHAR(TRUNC(to_date(getcentertime(c.id), 'YYYY-MM-DD HH24:MI')-1), 'YYYY-MM-DD HH24:MI'),co.DEFAULTTIMEZONE) + 86399000 AS toDate,
                c.ID AS CenterID
        FROM CENTERS c
        JOIN COUNTRIES co ON c.COUNTRY = co.ID
    )
SELECT
	c1.COUNTRY,
	c1.EXTERNAL_ID AS Cost,
	a.CENTER,
	c1.SHORTNAME AS CenterName,
	a.PERSON_CENTER || 'p' || a.PERSON_ID AS PersonId,
	CAST(EXTRACT('year' FROM age(p1.birthdate)) AS VARCHAR) AS Age,
	longToDate(a.START_TIME) AS Dato,
	--br.NAME AS AttendType,
	1 AS DropIn,
	NULL AS Booked,
/*	CASE
        WHEN ins2.CENTER IS NULL
        THEN NULL
        ELSE ins2.CENTER || 'p' || ins2.ID
    END instructorId,
    CASE
        WHEN ins2.CENTER IS NULL
        THEN NULL
        ELSE ins2.FIRSTNAME || ' ' || ins2.LASTNAME
    END instructorName */
	NULL AS instructorId,
	NULL AS instructorName
	
FROM
	ATTENDS a
JOIN PARAMS params ON params.CenterID = a.CENTER
LEFT JOIN BOOKING_RESOURCES br
ON
	a.BOOKING_RESOURCE_CENTER = br.CENTER
	AND a.BOOKING_RESOURCE_ID = br.ID
LEFT JOIN PERSONS p1
ON
	a.PERSON_CENTER = p1.CENTER
	AND a.PERSON_ID = p1.ID
LEFT JOIN CENTERS c1
ON
	a.CENTER = c1.ID
WHERE
	a.CENTER IN (:Scope)
	AND a.STATE LIKE 'ACTIVE'
	AND br.ATTEND_PRIVILEGE_ID = 1001 --PT
    AND a.START_TIME >= params.fromDate -- yesterday at midnight
	AND a.START_TIME < params.toDate -- yesterday at midnight +24 hours in ms
	
UNION ALL

SELECT
	c2.COUNTRY,
	c2.EXTERNAL_ID AS Cost,
	b.CENTER,
	c2.SHORTNAME AS CenterName,
	b.OWNER_CENTER || 'p' || b.OWNER_ID AS PersonID,
	CAST(EXTRACT('year' FROM age(p2.birthdate)) AS VARCHAR) AS Age,
	longToDate(b.STARTTIME) AS Dato,
	--b.NAME AS AttendType,
	NULL AS DropIn,
	1 AS Booked,
	CASE
        WHEN ins2.CENTER IS NULL
        THEN NULL
        ELSE ins2.CENTER || 'p' || ins2.ID
    END instructorId,
    CASE
        WHEN ins2.CENTER IS NULL
        THEN NULL
        ELSE ins2.FIRSTNAME || ' ' || ins2.LASTNAME
    END instructorName
FROM BOOKINGS b
JOIN PARAMS params ON params.CenterID = b.CENTER
LEFT JOIN STAFF_USAGE st2
ON
    b.center = st2.BOOKING_CENTER
    AND b.id = st2.BOOKING_ID
LEFT JOIN PERSONS ins2
ON
    st2.PERSON_CENTER = ins2.CENTER
    AND st2.PERSON_ID = ins2.ID
LEFT JOIN PERSONS p2
ON
	b.OWNER_CENTER = p2.CENTER
	AND b.OWNER_ID = p2.ID
LEFT JOIN CENTERS c2
ON
	b.CENTER = c2.ID
WHERE
	b.CENTER IN (:Scope)
	AND b.STATE LIKE 'ACTIVE'
	AND b.ACTIVITY IN (3008, 4807) -- se and no bookings
--	AND b.NAME LIKE 'Personlig Träning'
    AND b.STARTTIME >= params.fromDate -- yesterday at midnight
	AND b.STARTTIME < params.toDate -- yesterday at midnight +24 hours in ms

ORDER BY Dato
