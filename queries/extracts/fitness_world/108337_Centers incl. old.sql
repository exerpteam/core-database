-- The extract is extracted from Exerp on 2026-02-08
--  
select
c.ID,
c.name,
c.shortname,
c.startupdate
from centers c
Where c.ID in (:scope)
AND c.name not like '%Precreated%'
--AND c.name not like 'OLD%'
