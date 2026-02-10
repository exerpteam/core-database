-- The extract is extracted from Exerp on 2026-02-08
--  
select *
from BOOKING_RESOURCES br
Where
br.Type = 'ROOM'
AND br.STATE in ('ACTIVE', 'INACTIVE')
AND br.center in (:scope)