-- The extract is extracted from Exerp on 2026-02-08
--  
select 
b.center AS CLUB,
c.NAME AS CENTERNAME,
b.NAME AS CLASSNAME,
to_char (longtodate(b.starttime), 'dd-MM-YYYY HH24:MI') AS STARTTIME,
to_char (longtodate(b.stoptime), 'dd-MM-YYYY HH24:MI') AS ENDTIME,
b.state,
b.conflict
from bookings b
left join centers c
on b.center = c.ID
Where 
b.STATE = 'ACTIVE'
AND b.starttime >= :TODATE
--AND b.starttime < 572117619600000
AND b.center in (:scope)
