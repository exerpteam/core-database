Select 
a.name,
TO_CHAR(longtodateC(b.starttime,101), 'YYYY-MM-dd HH24:MI') AS "starttime",
TO_CHAR(longtodateC(b.stoptime,101), 'YYYY-MM-dd HH24:MI') AS "stoptime",
p.fullname AS "staff",
b.state,
TO_CHAR(longtodateC(b.cancelation_time,101), 'YYYY-MM-dd HH24:MI') AS "cancellationtime",
pa.participant_center || 'p' || pa.participant_id AS "memberID"
from bookings b
join activity a on b.activity = a.id
join staff_usage su on su.booking_center = b.center AND su.booking_id = b.id
join persons p on p.id = su.person_id and p.center = su.person_center
join participations pa on pa.booking_center = b.center AND pa.booking_id = b.id
where a.ACTIVITY_TYPE = 4
AND b.state = 'CANCELLED'
AND b.center = :center