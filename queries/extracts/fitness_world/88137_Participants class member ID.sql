-- This is the version from 2026-02-05
--  
select
b.CENTER CENTER,
c.NAME CENTERNAME,
b.NAME CLASS_NAME,
to_char (longtodate(b.starttime), 'dd-MM-YYYY HH24:MI') AS STARTTIME,
par.PARTICIPANT_CENTER || 'p' || par.PARTICIPANT_ID AS EXERPID,
p.FULLNAME AS Medlemsnavn
from participations par
left join bookings b
on par.BOOKING_CENTER = b.center
AND par.BOOKING_ID = b.id
left join centers c
on b.center = c.ID
LEFT JOIN PERSONS p
ON
p.CENTER = par.PARTICIPANT_CENTER
AND p.ID = par.PARTICIPANT_ID
where
b.STATE = 'ACTIVE'
AND par.state != 'CANCELLED'
AND b.starttime >= :FROMDATE
AND b.starttime <= :TODATE
AND b.CENTER in (:scope)
ORDER BY
b.CENTER,
STARTTIME,
(par.CENTER ||'book'|| par.ID)
