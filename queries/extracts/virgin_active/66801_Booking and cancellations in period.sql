 WITH
     params AS
     (
         SELECT
             /*+ materialize */
            :startdate                      AS PeriodStart,
             (:enddate + 86400 * 1000) - 1 AS PeriodEnd
         
     )
 SELECT
     par.PARTICIPANT_CENTER || 'p' || par.PARTICIPANT_ID                               AS "Member ID",
     c.WEB_NAME                                                                        AS "Club name",
     TO_CHAR(longtodateTZ(par.creation_time, 'Europe/Rome'), 'DD-MM-YYYY')           AS "Booking date",
     TO_CHAR(longtodateTZ(par.creation_time, 'Europe/Rome'), 'HH24:MI')              AS "Booking time",
     bo.NAME                                                                           AS "Class",
     bo.CLASS_CAPACITY                                                                 AS "Class capacity",
     TO_CHAR(longtodateTZ(bo.STARTTIME, 'Europe/Rome'), 'DD-MM-YYYY')        AS "Class start date",
     TO_CHAR(longtodateTZ(bo.STARTTIME, 'Europe/Rome'), 'HH24:MI')           AS "Class start time",
     TO_CHAR(longtodateTZ(bo.STARTTIME, 'Europe/Rome'), 'DD-MM-YYYY')        AS "Class start date",
     TO_CHAR(longtodateTZ(bo.STARTTIME, 'Europe/Rome'), 'HH24:MI')           AS "Class start time",
     par.state                                                                AS "Booking status",  
     par.cancelation_reason                                                   AS "Cancelation Reason", 
     TO_CHAR(longtodateTZ(par.cancelation_time, 'Europe/Rome'), 'DD-MM-YYYY') AS "Cancellation date",
     TO_CHAR(longtodateTZ(par.cancelation_time, 'Europe/Rome'), 'HH24:MI')    AS "Cancellation Time"      
  
     
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
join participations par
on      
par.BOOKING_CENTER = bo.center
AND par.BOOKING_ID = bo.id     
 
 WHERE
     bo.CENTER IN (:scope)
     AND bo.STARTTIME>= CAST(params.PeriodStart AS BIGINT)
     AND bo.STARTTIME<= CAST(params.PeriodEnd AS BIGINT)
     AND bo.STATE='ACTIVE'
 ORDER BY
     c.NAME,
     bo.starttime,
     bo.name
