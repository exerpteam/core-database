/**
* Extract to display resource schedule on the webpage and app (Bassängschema).
* First get all classes of type personal Training and Courses.
* Grouptrainings should always be visible and therefor joined with a Union clause.
* Club and time are given as arguments.
* Output is information of resource and time, this will be imported to the webpage with the ExtractAPI.
*
*/


/**
* Include Group traingings with activity_group = AQUA (8403) or activity_group = Företagsklass (3003).
* Activity_type = 4 is included as this is of typ Personalbokning, meaning staff has occupied the pool with intention (maintenance, education etc).
* Pay no attention to participations or not since the pool should be occupied anyway.
*/

SELECT 
	bookings.NAME,
	TO_CHAR(LONGTODATE(bookings.STARTTIME),'YYYY-MM-DD HH24:MI'),	
	TO_CHAR(LONGTODATE(bookings.STOPTIME),'YYYY-MM-DD HH24:MI'),	
	res.NAME,
	bookings.CLASS_CAPACITY,
bookings.STATE,
usages.STATE
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
	/** AND bookings.STATE IN ('ACTIVE','PLANNED')
	 AND usages.STATE = 'ACTIVE'*/
	AND bookings.STARTTIME > :startTime
	AND bookings.STARTTIME <= :stopTime + (1000 * 60 * 60 * 24)
	AND (
			(activity.ACTIVITY_TYPE = 2 AND 
				activity.ACTIVITY_GROUP_ID IN (8403, 3003))
			OR
			(activity.ACTIVITY_TYPE = 4)
	)		
	

	