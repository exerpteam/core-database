-- The extract is extracted from Exerp on 2026-02-08
--  
Select *
from
Activity a
where a.state = 'ACTIVE'
AND a.name is not null