-- The extract is extracted from Exerp on 2026-02-08
-- Count of showups made in client (ie by staff) in period
select 
    pa.center as center_for_booking,
    count (pa.participant_center||'p'||pa.participant_id) as
number_activity_bookings
from
    fw.participations pa
where
    pa.start_time >= :from_date
and pa.start_time <= (:to_date + 86400000)
and pa.showup_interface_type = 1 /*client*/
and pa.state like 'PARTICIPATION'
and pa.center in (:scope)
group by
    pa.center