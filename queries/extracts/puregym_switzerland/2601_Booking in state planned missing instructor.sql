Select distinct
b.center || 'book' || b.id   AS bookingID,
b.conflict,
c.name,
b.name,
TO_CHAR(longtodateC(b.starttime,b.center), 'YYYY-MM-dd HH24:MI'),
TO_CHAR(longtodateC(b.stoptime,b.center), 'YYYY-MM-dd HH24:MI'),
b.state,
su.person_center || 'p' || su.person_id   AS instructor
from bookings b
join staff_usage su
on b.center = su.booking_center
and b.id = su.booking_id
and su.state != 'CANCELLED'
join centers c
ON c.id = b.center

WHERE
b.state = 'PLANNED'