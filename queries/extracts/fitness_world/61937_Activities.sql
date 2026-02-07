-- This is the version from 2026-02-05
--  
Select *
from
Activity a
where a.state = 'ACTIVE'
AND a.name is not null