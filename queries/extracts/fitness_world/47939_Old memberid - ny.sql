-- This is the version from 2026-02-05
--  
select 
p.center ||'p'|| p.id, p.id, ext.txtvalue
from FW.PERSONS p

join FW.PERSON_EXT_ATTRS ext
on p.CENTER = ext.PERSONCENTER
and p.ID = ext.PERSONID
and ext.NAME = '_eClub_OldSystemPersonId'
and ext.TXTVALUE is not null

where
p.STATUS in (1,3)
and p.center in (:scope)