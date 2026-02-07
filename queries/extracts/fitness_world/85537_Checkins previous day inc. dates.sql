-- This is the version from 2026-02-05
--  
WITH params as MATERIALIZED
(
select
      :start_dato  as fromdate,
       :slut_dato  as todate,
        cen.id as centerid,
        cen.name as centername
        from
        centers cen

)

SELECT
	c.CHECKIN_CENTER AS CenterID,
	params.centername AS CenterNavn,
	to_char(longtodate(c.checkin_time),'DD-MM-YYYY') AS Dato,
		count(c.CHECKIN_CENTER) AS Antal

FROM
	fw.checkins c
JOIN
	params
ON
	c.checkin_center = params.centerid

WHERE 
c.CHECKIN_CENTER in (:scope)
AND c.checkin_time BETWEEN params.fromdate AND params.todate

GROUP BY
	c.CHECKIN_CENTER,
	params.centername,
	to_char(longtodate(c.checkin_time),'DD-MM-YYYY')

ORDER BY
c.CHECKIN_CENTER