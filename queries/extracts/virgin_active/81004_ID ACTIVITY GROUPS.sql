-- The extract is extracted from Exerp on 2026-02-08
--  
select
id,
name
from activity_group
where scope_id = 24
and state = 'ACTIVE'