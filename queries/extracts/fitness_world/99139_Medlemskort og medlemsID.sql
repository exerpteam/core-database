-- This is the version from 2026-02-05
--  
select 
e.identity,
p.center || 'p' || p.ID AS "Exerp ID"
from
entityidentifiers e
left join
persons p
on p.center = e.ref_center AND p.ID = e.ref_ID
where
e.IDMETHOD = 4
AND e.ENTITYSTATUS = 1
AND p.status in (1,3)
--AND p.PERSONTYPE != 8
AND p.center || 'p' || p.ID  = (:medlemsid)