/**
* Extract that include the future booked PT-sessions.
* Primary to be sent out to follow trends during the Coronaperiod.
* Activity_group_id = 2203
* Courses = 4803
*
*/
select
	c.country, a.name, count(b.id)
from 
	bookings b
join activity a on
	b.activity = a.id and
	a.activity_group_id in(2203,4803)
join centers c on
	b.center = c.id and
	c.country in ('SE','NO')
where 
	b.state in ('ACTIVE', 'PLANNED') and	
	b.starttime > datetolong(TO_CHAR(TRUNC(exerpsysdate()), 'YYYY-MM-DD HH24:MI')) and 
	b.starttime <= datetolong(TO_CHAR(TRUNC(exerpsysdate()+7), 'YYYY-MM-DD HH24:MI')) 
group by c.country,a.name
order by c.country
