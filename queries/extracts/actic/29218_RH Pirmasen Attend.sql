-- The extract is extracted from Exerp on 2026-02-08
--  
select att.center,
p.CENTER || 'p' || p.iD as PersonID, 
br.NAME,
TO_CHAR(longToDate(att.START_TIME), 'YYYY-MM-DD') As ATTEND_Time
 
from ATTENDS att

JOIN PERSONS P 
ON	
	att.PERSON_CENTER = P.CENTER
	AND att.PERSON_ID = P.ID

join BOOKING_RESOURCES br 
on br.center = att.BOOKING_RESOURCE_CENTER 
and br.id = att.BOOKING_RESOURCE_ID


where att.center IN ( :scope )
AND att.start_time >= :FromDate
AND att.start_time < :ToDate + 3600*1000*24
AND att.STATE = 'ACTIVE'
order by att.START_TIME