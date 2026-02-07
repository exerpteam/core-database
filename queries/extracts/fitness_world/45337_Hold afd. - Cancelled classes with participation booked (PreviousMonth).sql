-- This is the version from 2026-02-05
-- https://clublead.atlassian.net/browse/ST-3864
SELECT
    act.NAME  AS GLOBAL_ACTIVITY_ID,
to_char(longtodate(bo.STARTTIME), 'YYYY-MM-dd HH24:MI') as class_start,
    bo.name AS LOCAL_ACTIVITY_NAME,
    bo.CENTER as BOOKING_CENTER, 
    bo.CANCELLATION_REASON
FROM
     fw.persons p
JOIN fw.participations par
ON
    par.PARTICIPANT_CENTER = p.CENTER
    AND par.PARTICIPANT_ID = p.id
JOIN fw.bookings bo
ON
    par.BOOKING_ID = bo.ID
    AND par.BOOKING_CENTER = bo.CENTER
JOIN fw.activity act
ON
    bo.ACTIVITY = act.id
WHERE
        act.ACTIVITY_TYPE = 2 
    and bo.CENTER in (:Scope)
    and bo.STARTTIME >= exerpro.datetolong(to_char(TRUNC(ADD_MONTHS(exerpsysdate(), -1), 'MM'),'YYYY-MM-DD HH24:MI'))
    and bo.STARTTIME < exerpro.datetolong(to_char(TRUNC(exerpsysdate(), 'MM'),'YYYY-MM-DD HH24:MI')) 
	and bo.STATE = 'CANCELLED'
	and par.STATE = 'CANCELLED'
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
