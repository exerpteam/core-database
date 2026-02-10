-- The extract is extracted from Exerp on 2026-02-08
-- used to find ID for CO access scope extract
Select id, case when blocked is false then 0 when blocked is true then 1 end as blocked, name,parent,types,copied_from,root_area
from areas
where name like 'Full Estate%'
