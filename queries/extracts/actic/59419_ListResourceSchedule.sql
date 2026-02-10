-- The extract is extracted from Exerp on 2026-02-08
-- List resources that are occupied. Prefferably used to present simminglane availability on the webpage.
/**
* Extract to display resource schedule on the webpage and app (Bassängschema).
* First get all classes of type personal Training and Courses.
* Grouptrainings should always be visible and therefor joined with a Union clause.
* Club and time are given as arguments.
* Output is information of resource and time, this will be imported to the webpage with the ExtractAPI.
*
*/

/**
* Select all courses and Personal Training sessions. 
* Include participants to exclude non-booked session as the pool is then non-occupied.
*
*/
SELECT 
	bookings.NAME,
	TO_CHAR(LONGTODATE(bookings.STARTTIME),'YYYY-MM-DD HH24:MI'),	
	TO_CHAR(LONGTODATE(bookings.STOPTIME),'YYYY-MM-DD HH24:MI'),	
	res.NAME,
	COUNT(part.ID)
FROM BOOKINGS bookings 

JOIN BOOKING_RESOURCE_USAGE usages ON
	usages.BOOKING_CENTER = bookings.CENTER
	AND usages.BOOKING_ID = bookings.ID

JOIN BOOKING_RESOURCES res ON
	res.CENTER = usages.BOOKING_RESOURCE_CENTER
	AND res.ID = usages.BOOKING_RESOURCE_ID	

JOIN ACTIVITY activity ON
	bookings.ACTIVITY = activity.ID
JOIN PARTICIPATIONS part ON
	part.BOOKING_CENTER = bookings.CENTER
	AND part.BOOKING_ID = bookings.ID
WHERE 
	res.CENTER = :center
	AND res.STATE = 'ACTIVE'
	AND bookings.STATE = 'ACTIVE'
	AND usages.STATE = 'ACTIVE'
	AND bookings.STARTTIME > :startTime
	AND bookings.STARTTIME <= :stopTime + (1000 * 60 * 60 * 24)
	AND part.STATE IN ('PARTICIPATION','BOOKED')
	AND (
		(activity.ACTIVITY_TYPE IN (3,9))
	)		
GROUP BY 
	bookings.NAME,
	res.NAME,
	bookings.STARTTIME,
	bookings.STOPTIME



/**
* Include Group traingings with activity_group = AQUA (8403) or activity_group = Företagsklass (3003).
* Activity_type = 4 is included as this is of typ Personalbokning, meaning staff has occupied the pool with intention (maintenance, education etc).
* Pay no attention to participations or not since the pool should be occupied anyway.
*/
UNION ALL

SELECT 
	bookings.NAME,
	TO_CHAR(LONGTODATE(bookings.STARTTIME),'YYYY-MM-DD HH24:MI'),	
	TO_CHAR(LONGTODATE(bookings.STOPTIME),'YYYY-MM-DD HH24:MI'),	
	res.NAME,
	bookings.CLASS_CAPACITY
FROM BOOKINGS bookings 

JOIN BOOKING_RESOURCE_USAGE usages ON
	usages.BOOKING_CENTER = bookings.CENTER
	AND usages.BOOKING_ID = bookings.ID

JOIN BOOKING_RESOURCES res ON
	res.CENTER = usages.BOOKING_RESOURCE_CENTER
	AND res.ID = usages.BOOKING_RESOURCE_ID	

JOIN ACTIVITY activity ON
	bookings.ACTIVITY = activity.ID

WHERE 
	res.CENTER = :center
	AND res.STATE = 'ACTIVE'
	AND bookings.STATE != 'CANCELLED'
	AND usages.STATE != 'CANCELLED'
	AND bookings.STARTTIME > :startTime
	AND bookings.STARTTIME <= :stopTime + (1000 * 60 * 60 * 24)
	AND (
			(activity.ACTIVITY_TYPE = 2 AND 
				activity.ACTIVITY_GROUP_ID IN (8403, 3003))
			OR
			(activity.ACTIVITY_TYPE = 4)
	)		
	

	