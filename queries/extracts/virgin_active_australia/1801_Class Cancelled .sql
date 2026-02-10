-- The extract is extracted from Exerp on 2026-02-08
--  
WITH params AS (
    SELECT
        EXTRACT(EPOCH FROM $$startdate$$::TIMESTAMP) * 1000 AS PeriodStart,
        (EXTRACT(EPOCH FROM $$enddate$$::TIMESTAMP) * 1000 + 86400 * 1000) - 1 AS PeriodEnd
)
SELECT distinct
bo.center || 'book' || bo.id AS "Class ID",
c.SHORTNAME                                                                       AS "Club name",
bo.NAME AS "Class Name",
TO_CHAR(longtodateC(bo.STARTTIME,bo.center), 'YYYY-MM-DD') "Class Start Date",
     TO_CHAR(longtodateC(bo.STARTTIME,bo.center), 'HH24:MI') "Class Start Time",
TO_CHAR(longtodateC(bo.cancelation_time,bo.center), 'YYYY-MM-DD') "Class Cancelation Date",
TO_CHAR(longtodateC(bo.cancelation_time,bo.center), 'HH24:MI') "Class Cancelation Time",
staff.FULLNAME                                                                    AS "Instructor name",
cancelledby.fullname as "Canceled by",
	bo.STATE as "Class Status"

FROM 
	Bookings bo
CROSS JOIN
    params
  JOIN
     STAFF_USAGE su
	  ON
     bo.CENTER = su.BOOKING_CENTER
     AND bo.ID = su.BOOKING_ID
  JOIN
     PERSONS staff
 ON
     staff.CENTER = su.PERSON_CENTER
     AND staff.ID = su.PERSON_ID
	join persons cancelledby
 ON
     cancelledby.CENTER = bo.center
     AND cancelledby.ID = bo.cancelation_by_id
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
	bo.state = 'CANCELLED' --cancelation_time

	