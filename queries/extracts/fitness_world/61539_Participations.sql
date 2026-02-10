-- The extract is extracted from Exerp on 2026-02-08
--  
select
par.CENTER AS CLUB,
c.NAME AS CENTERNAME,
to_char (longtodate(par.creation_time), 'dd-MM-YYYY HH24:MI') AS CREATIONTIME,
to_char (longtodate(b.starttime), 'dd-MM-YYYY HH24:MI') AS STARTTIME,
par.PARTICIPANT_CENTER || 'p' || par.PARTICIPANT_ID AS EXERPID,
par.PARTICIPATION_NUMBER AS SEAT_NUMBER,
par.ON_WAITING_LIST AS ON_WAITINGLIST,
par.STATE AS BOOKINGSTATE
from participations par
left join bookings b
on par.BOOKING_CENTER = b.center
AND par.BOOKING_ID = b.id
left join centers c
on b.center = c.ID
where
--b.STATE = 'ACTIVE'
--AND par.state != 'CANCELLED'
--AND b.starttime >= TODATE
--AND b.starttime < 1610535600000
par.CENTER in (:scope)
--AND par.CREATION_TIME < 1608505200000
AND par.ID in (950008,989144, 975109, 977110, 943054, 945054)
