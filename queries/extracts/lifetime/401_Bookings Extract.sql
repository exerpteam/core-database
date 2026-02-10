-- The extract is extracted from Exerp on 2026-02-08
--  
**mbo broke this
select c.name as Center, longtodateC(b.starttime,100) as starttime, b.name as BookingName from bookings b
join centers c on c.id = b.center
WHERE b.state = 'ACTIVE'
ORDER BY center, starttime asc, b.name asc