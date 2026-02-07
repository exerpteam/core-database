SELECT
	c1.COUNTRY,
	c1.EXTERNAL_ID AS Cost,
	CAST ( a.CENTER AS VARCHAR(255)) AS CENTER,
	c1.SHORTNAME AS CenterName,
	a.person_center|| 'p' || a.person_ID AS PersonId,
	CAST(EXTRACT('year' FROM age(p1.birthdate)) AS VARCHAR) AS Age,
    TO_CHAR(longtodate(a.START_TIME), 'YYYY-MM-DD')AS dato,
	 TO_CHAR (longtodate(a.START_TIME), 'HH24:MI') AS STARTTIME,
	br.NAME AS AttendType,
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
	 a.STATE LIKE 'ACTIVE'
	AND br.ATTEND_PRIVILEGE_ID = 1001 --PT
	AND (a.person_center, a.person_ID) in (:memberid)


	
UNION ALL

SELECT
	c2.COUNTRY,
	c2.EXTERNAL_ID AS Cost,
	CAST ( b.CENTER AS VARCHAR(255)) AS CENTER,
	c2.SHORTNAME AS CenterName,
	b.OWNER_CENTER || 'p' || b.OWNER_ID AS PersonID,
	CAST(EXTRACT('year' FROM age(p2.birthdate)) AS VARCHAR) AS Age,
   TO_CHAR(longtodate(b.STARTTIME), 'YYYY-MM-DD')AS dato,
	 TO_CHAR (longtodate(b.STARTTIME), 'HH24:MI') AS STARTTIME,
	b.NAME AS AttendType,
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

 b.STATE LIKE 'ACTIVE'
AND st2.STATE != 'CANCELLED'
AND (b.OWNER_CENTER, b.OWNER_ID) in (:memberid)
AND b.ACTIVITY IN (3008, 4807, 19407, 18821, 18822, 18823, 22817, 23407, 22410, 22416, 22417, 22816, 23408, 22415, 22818, 23008, 22815, 23007, 23409, 24207) -- se and no bookings


ORDER BY Dato
