-- The extract is extracted from Exerp on 2026-02-08
--  
SELECT
    act.NAME  AS GLOBAL_ACTIVITY_ID,
to_char(longtodate(bo.STARTTIME), 'YYYY-MM-dd HH24:MI') as class_start,
    bo.name AS LOCAL_ACTIVITY_NAME,
    bo.CENTER as BOOKING_CENTER, 
    bo.CANCELLATION_REASON,
    count(bo.center) as customer_count
FROM
     persons p
JOIN participations par
ON
    par.PARTICIPANT_CENTER = p.CENTER
    AND par.PARTICIPANT_ID = p.id
JOIN bookings bo
ON
    par.BOOKING_ID = bo.ID
    AND par.BOOKING_CENTER = bo.CENTER
JOIN activity act
ON
    bo.ACTIVITY = act.id
WHERE
        act.ACTIVITY_TYPE = 2 
    and bo.center in (:scope)
    and bo.STARTTIME >= (:start_date)
    and bo.starttime <= (:end_date)
    and bo.state = 'CANCELLED'
    and par.state = 'CANCELLED'
group by
   act.NAME,
   bo.STARTTIME,
   bo.name,
   bo.CENTER, 
   bo.CANCELLATION_REASON
ORDER BY
    bo.center,
    bo.starttime, 
    act.name 
