-- The extract is extracted from Exerp on 2026-02-08
--  
SELECT
    p.CENTER||'p'||p.ID AS "MemberID",
	act.NAME AS GLOBAL_ACTIVITY_ID,
    to_char(longtodate(bo.STARTTIME), 'YYYY-MM-DD HH24:MI') AS class_start,
    bo.name AS LOCAL_ACTIVITY_NAME,
    bo.CENTER AS BOOKING_CENTER, 
    bo.CANCELLATION_REASON,
    count(*) AS customer_count,
    pr.name AS PRODUCT_NAME

FROM
    persons p
JOIN participations par
    ON par.PARTICIPANT_CENTER = p.CENTER AND par.PARTICIPANT_ID = p.ID
JOIN bookings bo
    ON par.BOOKING_ID = bo.ID AND par.BOOKING_CENTER = bo.CENTER
JOIN activity act
    ON bo.ACTIVITY = act.ID
JOIN subscriptions s
    ON s.OWNER_CENTER = p.CENTER AND s.OWNER_ID = p.ID
JOIN products pr
    ON pr.CENTER = s.SUBSCRIPTIONTYPE_CENTER AND pr.ID = s.SUBSCRIPTIONTYPE_ID
WHERE
    act.ACTIVITY_TYPE = 2 
    AND bo.CENTER IN (:scope)
    AND bo.STARTTIME >= (:start_date)
    AND bo.STARTTIME <= (:end_date)
    AND bo.name ILIKE '%zero%'
   	OR bo.name ILIKE '%bull%'
	
	AND s.state = 2
GROUP BY
	p.CENTER||'p'||p.ID,
    act.NAME,
    bo.STARTTIME,
    bo.name,
    bo.CENTER, 
    bo.CANCELLATION_REASON,
    pr.name
ORDER BY
    bo.CENTER,
    bo.STARTTIME, 
    act.NAME;
