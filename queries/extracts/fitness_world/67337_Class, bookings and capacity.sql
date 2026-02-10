-- The extract is extracted from Exerp on 2026-02-08
--  
WITH
    params AS Materialized
    (
        SELECT

            $$startdate$$                    as PeriodStart,
            ($$enddate$$ + 86400 * 1000) - 1  as PeriodEnd
        
    )
SELECT
	 c.id "Center ID",
    c.SHORTNAME                                                                       AS "Club name",
    bo.NAME                                                                           AS "Class name",
    ag.name                                                                           AS "Class activity group",
    bo.state                                                                          AS "Class state",
	bo.conflict
AS	"Booking conflict",
	staff.center || 'p' || staff.ID														AS "Instructor ID",
    staff.FULLNAME                                                                    AS "Instructor name",
   TO_CHAR(longtodateC(bo.STARTTIME, bo.CENTER), 'DAY')   Weekday  ,
	PES.TXTVALUE																		  AS "Instructor Status",
    TO_CHAR(longtodateC(bo.STARTTIME, bo.CENTER), 'DD-MM-YYYY')                       AS "Class start date",
    TO_CHAR(longtodateC(bo.STARTTIME, bo.CENTER), 'HH24:MI')                          AS "Class start time",
    TO_CHAR(longtodateC(bo.STOPTIME, bo.CENTER), 'HH24:MI')                           AS "Class stop time",
    TO_CHAR(longtodateTZ(bo.stoptime - bo.starttime, 'UTC'),'HH24:MI')                AS "Class duration", 
    br.NAME                                                                           AS "Class location",
    showup_waiting_cancel.total_booked                                                AS "Number of booked",
    bo.CLASS_CAPACITY                                                                 AS "Class capacity",
    showup_waiting_cancel.total_waiting                                               AS "Number of waitlist",
    bo.WAITING_LIST_CAPACITY                                                          AS "Waitlist capacity",
    showup_waiting_cancel.total                                                       AS "Total number of bookings",
    showup_waiting_cancel.total_cancel                                                AS "Number of cancelled",
    showup_waiting_cancel.total_showup                                                AS "Number of attended",
    showup_waiting_cancel.total_noshow                                                AS "Number of no shows",
    showup_waiting_cancel.total_anonymous                                             AS "Headcount Adjustment",
    bo.center || 'bk' || bo.ID                                                        AS "BookingId" 
FROM
    BOOKINGS bo
CROSS JOIN
    params
left JOIN
    STAFF_USAGE su
ON
    bo.CENTER = su.BOOKING_CENTER
    AND bo.ID = su.BOOKING_ID
    AND su.STATE = 'ACTIVE'
left JOIN
    BOOKING_RESOURCE_USAGE bru
ON
    bo.ID = bru.BOOKING_ID
    AND bo.CENTER = bru.BOOKING_CENTER
	AND bru.STATE = 'ACTIVE'
left JOIN
    PERSONS staff
ON
    staff.CENTER = su.PERSON_CENTER
    AND staff.ID = su.PERSON_ID
LEFT JOIN	
	PERSON_EXT_Attrs PES 
	ON staff.center = PES.Personcenter
	AND staff.id = PES.PERSONID
	AND PES.name = 'InstructorStatus'
left JOIN
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
    AND ac.activity_type = 2
JOIN
    ACTIVITY_GROUP ag
ON
    ag.ID = ac.activity_group_id
left JOIN
    (
        SELECT
            SUM( 1 )AS total,
            SUM(
                CASE
                    WHEN pa.state = 'PARTICIPATION'
                    THEN 1
                    ELSE 0
                END )AS total_showup,
            SUM(
                CASE
                    WHEN pa.state = 'PARTICIPATION' AND pa.participant_center is null
                    THEN 1
                    ELSE 0
                END )AS total_anonymous,                            
            SUM(
                CASE
                    WHEN pa.state = 'BOOKED'
                        AND pa.on_waiting_list = 0
                    THEN 1
                    ELSE 0
                END)AS total_booked,
            SUM(
                CASE
                    WHEN pa.state = 'BOOKED'
                        AND pa.on_waiting_list = 1
                    THEN 1
                    WHEN pa.state = 'CANCELLED'
                        AND pa.CANCELATION_REASON = 'NO_SEAT'
                    THEN 1                    
                    ELSE 0
                END)AS total_waiting,
            SUM(
                CASE
                    WHEN pa.state = 'CANCELLED'
                        AND pa.CANCELATION_REASON IN ('CENTER',
                                                      'BOOKING',
                                                      'USER')
                    THEN 1
                    ELSE 0
                END)AS total_cancel,
            SUM(
                CASE
                    WHEN pa.state = 'CANCELLED'
                        AND pa.CANCELATION_REASON IN ('NO_SHOW',
                                                      'USER_CANCEL_LATE')
                    THEN 1
                    ELSE 0
                END)AS total_noshow,
            pa.booking_center,
            pa.booking_id
        FROM
            participations pa
        CROSS JOIN
            params params1
        JOIN
            BOOKINGS bo1
        ON
            pa.booking_center = bo1.center
            AND pa.booking_id = bo1.id
        WHERE
            bo1.CENTER IN ($$scope$$)
            AND bo1.STARTTIME>= params1.PeriodStart
            AND bo1.STARTTIME<= params1.PeriodEnd
            AND bo1.STATE='ACTIVE'
        GROUP BY
            pa.booking_center,
            pa.booking_id )showup_waiting_cancel
ON
    showup_waiting_cancel.booking_center = bo.center
    AND showup_waiting_cancel.booking_id = bo.id
WHERE
  
     bo.STARTTIME>= params.PeriodStart
    AND bo.STARTTIME<= params.PeriodEnd
    AND bo.CENTER IN ($$scope$$)
	AND bo.STATE in ('ACTIVE','PLANNED')
ORDER BY
    c.NAME,
    bo.starttime,
    bo.name


