-- This is the version from 2026-02-05
--  
Select 
to_char (longtodate(par.creation_time), 'dd-MM-YYYY HH24:MI') AS CREATIONTIME,
to_char (longtodate(b.starttime), 'dd-MM-YYYY HH24:MI') AS STARTTIME,
par.PARTICIPANT_CENTER || 'p' || par.PARTICIPANT_ID AS EXERPID
from participations par
left join bookings b
on par.BOOKING_CENTER = b.center
AND par.BOOKING_ID = b.id
where
to_char (longtodate(par.creation_time), 'dd-MM-YYYY') = to_char (longtodate(b.starttime), 'dd-MM-YYYY')
AND par.state != 'CANCELLED'
AND b.starttime >= :TODATE
AND par.CENTER in (:scope)
ORDER BY
b.starttime,
par.creation_time
