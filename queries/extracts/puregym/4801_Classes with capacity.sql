-- The extract is extracted from Exerp on 2026-02-08
--  
 SELECT distinct
     TO_CHAR(longtodateTZ(bo.STARTTIME, 'Europe/London'), 'DAY')        AS "Day",
     TO_CHAR(longtodateTZ(bo.STARTTIME, 'Europe/London'), 'YYYY-MM-DD') AS "date",
     TO_CHAR(longtodateTZ(bo.STARTTIME, 'Europe/London'), 'HH24:MI')    AS "Time",
     bo.NAME                                                            AS "Name",
     staff.FULLNAME                                                     AS "Staff",
     br.NAME                                                            AS "Resource name",
     ac.DESCRIPTION                                                     AS "Description",
     c.NAME                                                             AS "Center",
     bo.CLASS_CAPACITY                                                  AS Capacity,
     bo.WAITING_LIST_CAPACITY                                           AS "Waiting list capacity"
 FROM
     BOOKINGS bo
 JOIN
     STAFF_USAGE su
 ON
     bo.CENTER = su.BOOKING_CENTER
     AND bo.ID = su.BOOKING_ID
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
 WHERE
     bo.CENTER IN (:scope)
     AND bo.STARTTIME>= :StartDate
     AND bo.STARTTIME<= :EndDate
     and bo.STATE='ACTIVE'
