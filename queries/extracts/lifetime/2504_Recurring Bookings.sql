-- The extract is extracted from Exerp on 2026-02-08
--  
select t.instructorname, t.BookingName, t.dayofweek, t.bookingresource ||' @ '|| t.centername as ResourceName, t.message
from
(
select distinct on (b.center||'bk'||b.id) b.center||'bk'||b.id as bknum,
p.fullname as InstructorName, 
substring(recurrence_data,3) as dayofweek,
b.name as BookingName,
br.name as bookingresource,
b.center as bookingcenterid,
c.name as CenterName,

concat('The first booking is ',TO_CHAR(longtodateC(b.starttime,100),'YYYY-MM-DD'),' @ ',TO_CHAR(longtodateC(b.starttime,100),'HH:MM'), ' and the last booking of this recurrence is set for ', recurrence_end, '.') as message
from bookings b
join centers c on c.id = b.center
join staff_usage su on su.booking_center = b.center and su.booking_id = b.id
join persons p on su.person_center = p.center and su.person_id = p.id
join booking_resource_usage brc on brc.booking_center = b.center and brc.booking_id = b.id
join booking_resources br on brc.booking_resource_center = br.center and brc.booking_resource_id = br.id
where b.state != 'cancelled'
and b.recurrence_end >= CURRENT_DATE
and recurrence_data is not NULL
and b.center in (:scope)

Order by bknum asc, instructorname ASC, bookingname asc, bookingresource asc
) t
order by t.InstructorName ASC, t.bookingname ASC, ResourceName