-- The extract is extracted from Exerp on 2026-02-08
--  
select distinct pig.id as old_remote_user_id, p.CURRENT_PERSON_CENTER || 'p' || p.CURRENT_PERSON_ID as new_remote_user_id
from PUREGYM.PERSONS p
join PUREGYM.PERSON_EXT_ATTRS pea on pea.PERSONCENTER = p.center and pea.personid = p.id and pea.name = '_eClub_OldSystemPersonId'
left join PUREGYM.PG_ID_VS_GUID pig on pig.GUID = pea.TXTVALUE