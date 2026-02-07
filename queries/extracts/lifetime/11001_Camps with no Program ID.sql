select b.center, a.name, longtodatec( b.starttime, b.center) booking_start_date, b.state
from bookings b, activity a
where b.booking_program_id is null
and b.activity = a.id
and a.activity_type in (11,12)
and b.state != 'CANCELLED'