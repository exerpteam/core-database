-- This is the version from 2026-02-05
--  
select 
    pa.center as center_for_booking, pa.participant_center||'p'||pa.participant_id as booking_persons
from
    participations pa
where
    pa.creation_time >= :from_date
and pa.creation_time <= (:to_date + 86400000)
and pa.user_interface_type = 2 /*kiosk*/
and pa.center in (:scope)
