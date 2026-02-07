-- This is the version from 2026-02-05
--  
select distinct
count(*),
pea.txtvalue
from person_ext_attrs pea
join persons p
on p.center = pea.personcenter
AND p.id = pea.personid
Where pea.name = '_eClub_Email'
AND pea.txtvalue is not null
AND p.status not in (4,5,7,8)
AND p.center in (:scope)
group by
pea.txtvalue
Having
count(*) > 1