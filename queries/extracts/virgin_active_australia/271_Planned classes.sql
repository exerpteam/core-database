-- This is the version from 2026-02-05
--  
WITH params AS (
    SELECT
        EXTRACT(EPOCH FROM $$startdate$$::TIMESTAMP) * 1000 AS PeriodStart,
        (EXTRACT(EPOCH FROM $$enddate$$::TIMESTAMP) * 1000 + 86400 * 1000) - 1 AS PeriodEnd
)
SELECT 
	bo.STATE,
     bru.STATE,
	bo.center || 'book' || bo.id AS "Class ID",
	 c.SHORTNAME                                                                       AS "Club name",
	 bo.NAME,
	 staff.FULLNAME                                                                    AS "Instructor name",
         PES.TXTVALUE                                                                                                                                              AS "Instructor Status",
TO_CHAR(longtodateC(bo.STARTTIME,bo.center), 'YYYY-MM-DD') "Class Start Date",
     TO_CHAR(longtodateC(bo.STARTTIME,bo.center), 'HH24:MI') "Class Start Time",
TO_CHAR(longtodateC(bo.STOPTIME,bo.center), 'YYYY-MM-DD') "Class Stop Date",
     TO_CHAR(longtodateC(bo.STOPTIME,bo.center), 'HH24:MI') "Class Stop Time",

TO_CHAR(
  ((bo.STOPTIME - bo.STARTTIME)/60000) * interval '1 minute',
  'HH24:MI'
) AS "Class duration"
,
     br.NAME                                                                           AS "Class location"
FROM 
	Bookings bo
CROSS JOIN
    params
  JOIN
     STAFF_USAGE su
	  ON
     bo.CENTER = su.BOOKING_CENTER
     AND bo.ID = su.BOOKING_ID
     AND su.STATE = 'ACTIVE'
  JOIN
     PERSONS staff
 ON
     staff.CENTER = su.PERSON_CENTER
     AND staff.ID = su.PERSON_ID
 LEFT JOIN
         PERSON_EXT_Attrs PES
         ON staff.center = PES.Personcenter
         AND staff.id = PES.PERSONID
         AND PES.name = 'InstructorStatus'
 JOIN
	ACTIVITY ac
	ON ac.ID = bo.ACTIVITY
     /* Activity type 'Class' only*/
    AND 
	ac.activity_type = 2
  JOIN
     BOOKING_RESOURCE_USAGE bru
 ON
     bo.ID = bru.BOOKING_ID
     AND bo.CENTER = bru.BOOKING_CENTER
     AND bru.STATE = 'ACTIVE'
 JOIN
     BOOKING_RESOURCES br
	ON br.CENTER = bru.BOOKING_RESOURCE_CENTER
    AND br.ID = bru.BOOKING_RESOURCE_ID
 LEFT JOIN
     CENTERS c
 ON
     c.ID = bo.CENTER
	 
WHERE 
	bo.STARTTIME>= params.PeriodStart
AND 
	bo.STOPTIME<= params.PeriodEnd
AND 
	bo.CENTER IN ($$scope$$) 
AND
	bo.state <> 'CANCELLED'
	