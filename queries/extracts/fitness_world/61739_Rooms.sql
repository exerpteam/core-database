-- This is the version from 2026-02-05
--  
select *
from BOOKING_RESOURCES br
Where
br.Type = 'ROOM'
AND br.STATE in ('ACTIVE', 'INACTIVE')
AND br.center in (:scope)