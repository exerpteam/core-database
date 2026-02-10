-- The extract is extracted from Exerp on 2026-02-08
-- regardles of cancellation of bookings
select 
    pa.center as center_for_booking,
    count(pa.center) as number_of_bookings
from
    fw.participations pa
where
    pa.creation_time >= :from_date
and pa.creation_time <= (:to_date + 86400000)
and pa.user_interface_type = 3 /*kiosk*/
and pa.center in (:scope)
group by
    pa.center