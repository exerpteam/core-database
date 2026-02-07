-- This is the version from 2026-02-05
--  
WITH params AS Materialized
(
SELECT
   CAST(datetolong(to_char(current_date-1,'YYYY-MM-DD HH24:MI')) AS BIGINT) as from_ts,
   CAST(datetolong(to_char(current_date,'YYYY-MM-DD HH24:MI')) AS BIGINT) as to_ts
)
SELECT
	c.CHECKIN_CENTER 									AS CenterID,
	cen.NAME 											AS CenterNavn,
	to_char(longtodate(c.checkin_time),'DD-MM-YYYY') 	AS Dato,
	count(c.CHECKIN_CENTER) 							AS Antal

FROM
	params,
	checkins c

JOIN
	CENTERS cen
ON
	c.CHECKIN_CENTER = cen.ID

WHERE
        c.CHECKIN_TIME >= PARAMS.FROM_TS
        AND c.CHECKIN_TIME < PARAMS.TO_TS
AND	c.CHECKIN_CENTER in (:scope)

GROUP BY
	c.CHECKIN_CENTER,
	cen.NAME,
	to_char(longtodate(c.checkin_time),'DD-MM-YYYY')

ORDER BY
c.CHECKIN_CENTER