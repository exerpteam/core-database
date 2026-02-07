WITH PARAMS AS
(
	SELECT
        CAST(extract(epoch FROM timezone('America/New_York',CAST(:FromDate AS TIMESTAMP))) AS bigint)*1000 AS fromDate,
        CAST(extract(epoch FROM timezone('America/New_York',CAST(TO_DATE(
:ToDate ,'YYYY-MM-DD') + interval '1 day' AS TIMESTAMP))) AS bigint)*1000 - 1 AS toDate
)
SELECT
        c.person_center || 'p' || c.person_id AS PersonId,
        TO_CHAR(longtodateC(c.checkin_time, c.person_center), 'YYYY-MM-DD HH24:MI') AS Checkin_Time,
        TO_CHAR(longtodateC(c.checkout_time, c.person_center), 'YYYY-MM-DD HH24:MI') AS Checkout_Time, 
		c.checkin_center,
        (CASE c.checkin_result WHEN 0 THEN 'UNKNOWN' WHEN 1 THEN 'ACCESS_GRANTED' WHEN 2 THEN 'PRESENCE_REGISTERED' WHEN 3 THEN 'ACCESS_DENIED' END) AS Checkin_State
FROM
        chelseapiers.checkins c
CROSS JOIN PARAMS par
WHERE
		c.checkin_center IN (:Scope)
		AND c.checkin_result IN (:CheckinState)
        AND c.checkin_time > par.fromDate
        AND c.checkin_time < par.toDate