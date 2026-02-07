-- This is the version from 2026-02-05
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
