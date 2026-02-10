-- The extract is extracted from Exerp on 2026-02-08
--  
select DISTINCT
b.CENTER CENTER,
c.NAME CENTERNAME,
par.CENTER ||'book'|| par.ID BOOKING_ID,
to_char (longtodate(par.creation_time), 'dd-MM-YYYY HH24:MI') AS CREATIONTIME,
b.NAME CLASS_NAME,
to_char (longtodate(b.starttime), 'dd-MM-YYYY HH24:MI') AS STARTTIME
from participations par
left join bookings b
on par.BOOKING_CENTER = b.center
AND par.BOOKING_ID = b.id
left join centers c
on b.center = c.ID
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
