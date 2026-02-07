 WITH
     params AS
     (
         SELECT
             /*+ materialize */
             $$startdate$$                    AS PeriodStart,
             ($$enddate$$ + 86400 * 1000) - 1 AS PeriodEnd
         
     )

SELECT 
	bo.STATE,
     bru.STATE,
	 c.SHORTNAME                                                                       AS "Club name",
	 bo.NAME,
	 staff.FULLNAME                                                                    AS "Instructor name",
         PES.TXTVALUE                                                                                                                                              AS "Instructor Status",
     TO_CHAR(longtodateC(bo.STARTTIME, bo.CENTER), 'DD-MM-YYYY')                       AS "Class start date",
     TO_CHAR(longtodateC(bo.STARTTIME, bo.CENTER), 'HH24:MI')                          AS "Class start time",
	 TO_CHAR(longtodateC(bo.STOPTIME, bo.CENTER), 'HH24:MI')                          AS "Class stop time",
     TO_CHAR(((bo.stoptime - bo.starttime)/60000) * interval '1 min', 'HH24:MI') AS "Class duration",
     br.NAME                                                                           AS "Class location"
FROM 
	Bookings bo
CROSS JOIN
    params
 LEFT JOIN
     STAFF_USAGE su
	  ON
     bo.CENTER = su.BOOKING_CENTER
     AND bo.ID = su.BOOKING_ID
     AND su.STATE = 'ACTIVE'
	LEFT  JOIN
     PERSONS staff
 ON
     staff.CENTER = su.PERSON_CENTER
     AND staff.ID = su.PERSON_ID
 LEFT JOIN
         PERSON_EXT_Attrs PES
         ON staff.center = PES.Personcenter
         AND staff.id = PES.PERSONID
         AND PES.name = 'InstructorStatus'
LEFT JOIN
	ACTIVITY ac
	ON ac.ID = bo.ACTIVITY
     /* Activity type 'Class' only*/
    
	
	
 LEFT JOIN
     BOOKING_RESOURCE_USAGE bru
 ON
     bo.ID = bru.BOOKING_ID
     AND bo.CENTER = bru.BOOKING_CENTER
     AND bru.STATE = 'ACTIVE'
LEFT JOIN
     BOOKING_RESOURCES br
	ON br.CENTER = bru.BOOKING_RESOURCE_CENTER
    AND br.ID = bru.BOOKING_RESOURCE_ID
 LEFT JOIN
     CENTERS c
 ON
     c.ID = bo.CENTER
	 
WHERE 
	bo.STARTTIME>= CAST(params.PeriodStart AS BIGINT)
AND 
	bo.STOPTIME<= CAST(params.PeriodEnd AS BIGINT)
AND 
	bo.CENTER IN ($$scope$$) 
AND 
	ac.activity_type = 2
AND
	bo.state <> 'CANCELLED'
	