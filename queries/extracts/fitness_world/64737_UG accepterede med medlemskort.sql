-- This is the version from 2026-02-05
--  
select distinct
p.center ||'p'|| p.id AS Person_id,
p.external_id,
p.center AS Home_Club,
pea.txtvalue,
pr.globalid
from PERSON_EXT_ATTRS pea
left join Persons p
ON pea.PERSONCENTER= P.CENTER AND pea.PERSONID = P.ID
left join entityidentifiers e
on p.center = e.ref_center AND p.ID = e.ref_ID
left join subscriptions s
on p.center = s.owner_center AND p.ID = s.owner_id
LEFT join PRODUCTS PR ON PR.CENTER = S.SUBSCRIPTIONTYPE_CENTER AND PR.ID = S.SUBSCRIPTIONTYPE_ID
where pea.NAME = 'FWTERMSANDCONDEXUG'
AND p.center in (:scope)
AND pea.txtvalue is not null
AND p.external_id is not null
AND pr.globalid = 'UG_FITNESS_ALL'
AND e.ENTITYSTATUS = 1