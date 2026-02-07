select
je.person_center ||'p'|| je.person_id,
*
from journalentries je

join persons p
on
p.center = je.person_center
and
p.id = je.person_id
and   (p.center, p.id)  in (:member)

where 
je.name = 'Person type documentation'
and longtodate(je.creation_time) > '2025-01-13'
and p.persontype = 1 
