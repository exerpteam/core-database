 WITH
 params AS
     (
         SELECT
             CAST((TRUNC(CURRENT_TIMESTAMP)- 1 - to_date('1970-01-01','YYYY-MM-DD')) AS BIGINT)*24*3600*1000 AS PeriodStart,
             CAST((TRUNC(CURRENT_TIMESTAMP)-to_date('1-1-1970','MM-DD-YYYY')) AS BIGINT)*24*3600*1000 AS PeriodEnd
         
        )
 SELECT
     c.SHORTNAME                                                                        AS "Club name",
     bo.NAME                                                                           AS "Class name",
     ag.name                                                                           AS "Class activity group",
     staff.FULLNAME                                                                    AS "Instructor name",
     TO_CHAR(longtodateTZ(bo.STARTTIME, 'Europe/London'), 'DD-MM-YYYY')        AS "Class start date",
     TO_CHAR(longtodateTZ(bo.STARTTIME, 'Europe/London'), 'HH24:MI')           AS "Class start time",
     TO_CHAR(((bo.stoptime - bo.starttime)/60000) * interval '1 min', 'HH24:MI') AS "Class duration",
     br.NAME                                                                           AS "Class location",
     showup_waiting_cancel.total_booked                                                AS "Number of booked",
     bo.CLASS_CAPACITY                                                                 AS "Class capacity",
         showup_waiting_cancel.total_waiting                                               AS "Number of waitlist",
     bo.WAITING_LIST_CAPACITY                                                          AS "Waitlist capacity",
     showup_waiting_cancel.total                                                       AS "Total number of bookings",
     showup_waiting_cancel.total_cancel                                                AS "Number of cancelled",
     showup_waiting_cancel.total_showup                                                AS "Number of attended",
     showup_waiting_cancel.total_noshow                                                AS "Number of no shows",
     showup_waiting_cancel.total_anonymous                                             AS "Headcount Adjustment" ,
        bo.center || 'bk' || bo.ID                                             AS "BookingId"
 FROM
     BOOKINGS bo
 CROSS JOIN
     params
 JOIN
     STAFF_USAGE su
 ON
    bo.CENTER = su.BOOKING_CENTER
     AND bo.ID = su.BOOKING_ID
     AND su.STATE = 'ACTIVE'
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
 JOIN
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
     bo.CENTER IN ($$scope$$)
     AND bo.STARTTIME>= params.PeriodStart
     AND bo.STARTTIME<= params.PeriodEnd
     AND bo.STATE='ACTIVE'
 ORDER BY
     c.NAME,
     bo.starttime,
     bo.name
