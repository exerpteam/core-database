Select
e.identity,
p.center ||'p'|| p.id AS "Person ID"
from Entityidentifiers e join persons p on e.ref_center = p.center and e.ref_id = p.id
where e.entitystatus = 1 AND e.identity ~ '[a-z]'