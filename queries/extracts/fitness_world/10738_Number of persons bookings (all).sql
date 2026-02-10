-- The extract is extracted from Exerp on 2026-02-08
-- f
select 
    pa.center as center_for_booking,
    count (distinct(pa.participant_center||'p'||pa.participant_id)) as booking_persons
from
    fw.participations pa
where
    pa.creation_time >= :from_date
and pa.creation_time <= (:to_date + 86400000)
and pa.center in (:scope)
group by
    pa.center