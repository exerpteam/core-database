-- The extract is extracted from Exerp on 2026-02-08
--  
select
count (distinct(par.PARTICIPANT_CENTER || 'p' || par.PARTICIPANT_ID)) as Antal_bookinger,
b.NAME AS Holdnavn,
b.CLASS_CAPACITY AS Hold_kapacitet,
c.ID AS CenterID,
c.NAME AS centernavn,
to_char (longtodate(b.starttime), 'dd-MM-YYYY HH24:MI') AS starttid
from participations par
left join bookings b
on par.BOOKING_CENTER = b.center
AND par.BOOKING_ID = b.id
left join centers c
on b.center = c.ID
where
b.STATE = 'ACTIVE'
AND par.state != 'CANCELLED'
AND longtodate(b.starttime)>= current_timestamp
AND par.CENTER in (:scope)
GROUP BY
b.NAME,
b.CLASS_CAPACITY,
c.NAME,
c.ID,
to_char (longtodate(b.starttime), 'dd-MM-YYYY HH24:MI')