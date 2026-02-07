-- This is the version from 2026-02-05
--  
select
distinct p.ssn,
p.center || 'p' || p.ID,
p.fullname,
p.status
from persons p
where p.SSN in (:SSN)
AND p.status in (1,3)
