-- The extract is extracted from Exerp on 2026-02-08
-- Count usage of resource grouped by center
/**
* Creator: Stein Rudsengen
* ServiceTicket: N/A
* Purpose: Count number of active attends grouped by center and
* resource
*/
select
	att.center, 
	br.NAME, 
	count(att.center) as attends 
from ATTENDS att 
join BOOKING_RESOURCES br on 
	br.center = att.BOOKING_RESOURCE_CENTER and 
	br.id = att.BOOKING_RESOURCE_ID
where 
	att.center IN ( :scope )
and 
	att.START_TIME BETWEEN :From_date AND :To_date and 
	att.STATE = 'ACTIVE'
group by att.center, br.NAME
order by att.center