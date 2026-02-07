 WITH
     params AS
     (
         SELECT
             /*+ materialize */
             $$startdate$$                    AS PeriodStart,
             ($$enddate$$ + 86400 * 1000) - 1 AS PeriodEnd
         
     )
 SELECT
     c.SHORTNAME                                                                       AS "Club name",
     bo.NAME                                                                           AS "Booking name",
         -- staff.center || 'p' || staff.ID                                                                                                         AS "Instructor ID",
     -- staff.FULLNAME                                                                    AS "Instructor name",
         -- PES.TXTVALUE                                                                                                                                              AS "Instructor Status",
     TO_CHAR(longtodateC(bo.STARTTIME, bo.CENTER), 'DD-MM-YYYY')                       AS "Class start date",
     TO_CHAR(longtodateC(bo.STARTTIME, bo.CENTER), 'HH24:MI')                          AS "Class start time",
     TO_CHAR(longtodateC(bo.STOPTIME, bo.CENTER), 'HH24:MI')                          AS "Class end time",
     br.NAME                                                                           AS "Class location"
 FROM
     BOOKINGS bo
 CROSS JOIN
     params
 -- JOIN
     -- STAFF_USAGE su
 -- ON
     -- bo.CENTER = su.BOOKING_CENTER
     -- AND bo.ID = su.BOOKING_ID
     -- AND su.STATE = 'ACTIVE'
 JOIN
     BOOKING_RESOURCE_USAGE bru
 ON
     bo.ID = bru.BOOKING_ID
     AND bo.CENTER = bru.BOOKING_CENTER
         AND bru.STATE = 'ACTIVE'
 -- JOIN
     -- PERSONS staff
 -- ON
     -- staff.CENTER = su.PERSON_CENTER
     -- AND staff.ID = su.PERSON_ID
 -- LEFT JOIN
         -- PERSON_EXT_Attrs PES
         -- ON staff.center = PES.Personcenter
         -- AND staff.id = PES.PERSONID
         -- AND PES.name = 'InstructorStatus'
 JOIN
     BOOKING_RESOURCES br
 ON
     br.CENTER = bru.BOOKING_RESOURCE_CENTER
     AND br.ID = bru.BOOKING_RESOURCE_ID
 JOIN
     CENTERS c
 ON
     c.ID = bo.CENTER
 JOIN
     ACTIVITY ac
 ON
     ac.ID = bo.ACTIVITY
     /* Activity type 'Class' only*/
    --AND ac.activity_type <> 2
 JOIN
     ACTIVITY_GROUP ag
 ON
     ag.ID = ac.activity_group_id
	 
	  WHERE
		bo.STARTTIME>= CAST(params.PeriodStart AS BIGINT)
     AND 
		bo.STARTTIME<= CAST(params.PeriodEnd AS BIGINT)
     AND 
		bo.CENTER IN ($$scope$$)
	AND 
		br.Type = 'COURT'
ORDER BY
	C.SHORTNAME,
		br.NAME,
		bo.STARTTIME