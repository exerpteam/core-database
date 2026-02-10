-- The extract is extracted from Exerp on 2026-02-08
--  
 WITH
     params AS
     (
         SELECT
             /*+ materialize */
             $$startdate$$                      AS PeriodStart,
             ($$enddate$$ + 86400 * 1000) - 1 AS PeriodEnd
         
     )
 SELECT
     c.WEB_NAME AS "Club name",
     bo.NAME AS "Class name",
     ag.name AS "Class activity group",
     staff.FULLNAME AS "Instructor name",
     TO_CHAR(longtodateTZ(bo.STARTTIME, 'Europe/London'), 'DD-MM-YYYY')        AS "Class start date",
     TO_CHAR(longtodateTZ(bo.STARTTIME, 'Europe/London'), 'HH24:MI')           AS "Class start time",
     br.NAME AS "Class location",
     bo.CLASS_CAPACITY AS "Class capacity",
     bo.WAITING_LIST_CAPACITY AS "Waitlist capacity"
 FROM
     BOOKINGS bo
 CROSS JOIN
     params
 JOIN
     STAFF_USAGE su
 ON
     bo.CENTER = su.BOOKING_CENTER
     AND bo.ID = su.BOOKING_ID
     --AND su.STATE = 'ACTIVE'
 JOIN
     BOOKING_RESOURCE_USAGE bru
 ON
     bo.ID = bru.BOOKING_ID
     AND bo.CENTER = bru.BOOKING_CENTER
 JOIN
     PERSONS staff
 ON
     staff.CENTER = su.PERSON_CENTER
     AND staff.ID = su.PERSON_ID
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
     AND ac.activity_type = 2
 JOIN
     ACTIVITY_GROUP ag
 ON
     ag.ID = ac.activity_group_id
 WHERE
     bo.CENTER IN ($$scope$$)
     AND (('ALL' IN ($$activity_group$$))
            OR (ag.name like replace($$activity_group$$,'*','%')))
     AND (('ALL' IN ($$class_name$$))
            OR (bo.name like replace($$class_name$$,'*','%')))
     AND (('ALL' IN ($$instructor_name$$))
            OR (staff.FULLNAME  like replace($$instructor_name$$,'*','%')))
     AND bo.STARTTIME>= CAST(params.PeriodStart AS BIGINT)
     AND bo.STARTTIME<= CAST(params.PeriodEnd AS BIGINT)
     --AND bo.STATE='ACTIVE'
 ORDER BY
     c.NAME,
     bo.starttime,
     bo.name
