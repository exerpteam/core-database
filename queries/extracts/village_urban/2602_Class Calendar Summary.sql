-- The extract is extracted from Exerp on 2026-02-08
--  
WITH
    params AS
    (
        SELECT
            /*+ materialize */
            $$StartDate$$                      AS PeriodStart,
            ($$EndDate$$ + 86400 * 1000) - 1   AS PeriodEnd
    )
SELECT
    c.NAME                                                                           AS "Center",
    TO_CHAR(longtodateTZ(bo.STARTTIME, 'Europe/London'), 'DAY')              AS "Day",
    TO_CHAR(longtodateTZ(bo.STARTTIME, 'Europe/London'), 'YYYY-MM-DD')       AS "Date",
    TO_CHAR(longtodateTZ(bo.STARTTIME, 'Europe/London'), 'HH24:MI')          AS "Time",
    bo.NAME                                                                          AS "Name",
    staff.FULLNAME                                                                   AS "Staff",
    br.NAME                                                                          AS "Resource name",
    ag.name                                                                          AS "Activity type",
    showup_waiting.total_showup                                                      AS "Total show up",
    bo.CLASS_CAPACITY                                                                AS "Club Capacity",
    ROUND((showup_waiting.total_showup/ bo.CLASS_CAPACITY)*100, 1)                   AS "Club Capacity show up ratio %",
    GREATEST(COALESCE(brc.maximum_participations, ac.max_participants), ac.max_participants) AS "Resource capacity",
    ROUND((showup_waiting.total_showup/ GREATEST(COALESCE(brc.maximum_participations, ac.max_participants), ac.max_participants))*100, 1) AS "Resource show up ratio %",		
    bo.WAITING_LIST_CAPACITY                                                         AS "Waiting list capacity",
    showup_waiting.total_waiting                                                     AS "Total waiting list",
    ROUND((showup_waiting.total_waiting/ CASE WHEN bo.WAITING_LIST_CAPACITY = 0 THEN 1 ELSE bo.WAITING_LIST_CAPACITY END)*100, 1)                 AS "Waiting list ratio %",    
    ac.DESCRIPTION                                                                   AS "Description",
    bo.STATE                                                                         AS "State"
FROM
    BOOKINGS bo
CROSS JOIN
    params    
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
    BOOKING_RESOURCE_CONFIGS brc
ON
    brc.BOOKING_RESOURCE_CENTER = br.CENTER
    AND brc.BOOKING_RESOURCE_ID = br.ID
JOIN
    CENTERS c
ON
    c.ID = bo.CENTER
JOIN
    ACTIVITY ac
ON
    ac.ID = bo.ACTIVITY
JOIN
    ACTIVITY_GROUP ag
ON
    ag.ID = ac.activity_group_id
    
JOIN (select SUM(
                 CASE
                   WHEN pa.state = 'PARTICIPATION'
                   THEN 1
                   ELSE 0
                 END )AS total_showup,
             SUM(
                 CASE
                   WHEN pa.state = 'BOOKED'
                   AND pa.on_waiting_list = 1
                   THEN 1
                   ELSE 0
                 END)AS total_waiting,
             pa.booking_center,
             pa.booking_id
        from
          participations pa
        CROSS JOIN
           params params1
        JOIN  BOOKINGS bo1       
        ON  pa.state IN( 'PARTICIPATION',
                'BOOKED')
            AND pa.booking_center = bo1.center
            AND pa.booking_id = bo1.id
       WHERE
           bo1.CENTER IN ($$scope$$)
           AND bo1.STARTTIME>= params1.PeriodStart
           AND bo1.STARTTIME<= params1.PeriodEnd
           AND bo1.STATE='ACTIVE'
       group by 
         pa.booking_center,
         pa.booking_id
      )showup_waiting 
ON
  showup_waiting.booking_center = bo.center
  AND showup_waiting.booking_id = bo.id       
WHERE
    bo.CENTER IN ($$scope$$)
    and ag.id in ($$activity_type$$)
    AND bo.STARTTIME>= params.PeriodStart
    AND bo.STARTTIME<= params.PeriodEnd
    AND bo.STATE='ACTIVE'
GROUP BY
    c.NAME,
    TO_CHAR(longtodateTZ(bo.STARTTIME, 'Europe/London'), 'DAY') ,
    TO_CHAR(longtodateTZ(bo.STARTTIME, 'Europe/London'), 'YYYY-MM-DD'),
    TO_CHAR(longtodateTZ(bo.STARTTIME, 'Europe/London'), 'HH24:MI') ,
    bo.NAME,
    bo.id,
    staff.FULLNAME ,
    br.NAME ,
    ag.name,
    bo.CLASS_CAPACITY ,
    showup_waiting.total_showup,
    showup_waiting.total_waiting,
    GREATEST(COALESCE(brc.maximum_participations, ac.max_participants), ac.max_participants) ,
    ROUND((ac.max_participants/ac.max_participants)*100, 2) ,
    bo.WAITING_LIST_CAPACITY ,
    ac.DESCRIPTION ,
    bo.STATE
