/*Export details that are not existing in Exerps CourseAPI.
This should be extracted on the website and additional information added to course.
Parameters are for any booking in the course and all the other bookings will be extracted as well*/
SELECT	
	b2.NAME,
	TO_CHAR(LONGTODATE(b2.STARTTIME),'YYYY-MM-DD HH24:MI') AS STARTDATUM,
	b2.CLASS_CAPACITY AS KAPACITET,
	COUNT (DISTINCT par.ID) as BOKADE,
	CASE
		WHEN b2.CLASS_CAPACITY = COUNT (DISTINCT par.ID) THEN 'FULL'
		ELSE ''
	END AS FULLBOKAD
FROM BOOKINGS b2
LEFT JOIN PARTICIPATIONS par
	ON par.BOOKING_CENTER = b2.CENTER
	AND par.BOOKING_ID = b2.ID
	AND par.STATE IN('BOOKED','PARTICIPATION','PARTICIPATING')
LEFT JOIN ACTIVITY act ON
	b2.ACTIVITY = act.ID
WHERE
	b2.BOOKING_PROGRAM_ID IS NOT NULL
	AND b2.STATE = 'ACTIVE'
	AND b2.STARTTIME > :fromDate
	AND b2.STARTTIME < :toDate
	AND b2.CENTER = :center
	AND act.ACTIVITY_TYPE = 9
GROUP BY 
	b2.ID,
	b2.NAME,
	b2.CLASS_CAPACITY,
	b2.STARTTIME
ORDER BY 
	b2.NAME,
	b2.STARTTIME