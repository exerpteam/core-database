-- The extract is extracted from Exerp on 2026-02-08
--  
select 
p.center ||'p'|| p.id, p.id, ext.txtvalue,
CASE  p.STATUS  WHEN 0 THEN 'LEAD'  WHEN 1 THEN 'ACTIVE'  WHEN 2 THEN 'INACTIVE'  WHEN 3 THEN 'TEMPORARYINACTIVE'  WHEN 4 THEN 'TRANSFERED'  WHEN 5 THEN 'DUPLICATE'  WHEN 6 THEN 'PROSPECT'  WHEN 7 THEN 'DELETED' ELSE 'UNKNOWN' END AS STATUS
from PERSONS p

join PERSON_EXT_ATTRS ext
on p.CENTER = ext.PERSONCENTER
and p.ID = ext.PERSONID
and ext.NAME = '_eClub_OldSystemPersonId'
and ext.TXTVALUE is not null

where
-- p.STATUS not in (1,3)
 p.ssn is null
and p.center in (:scope)
