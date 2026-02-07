Select p.center,
p.id,
i.identity,
i.ENTITYSTATUS,
1.start_time,
i.stop_time
from persons p

left join entityidentifiers i
on
i.ref_center = p.center and i.ref_id = p.id 
Where
i.ref_type = 1 and
( i.identity = :cardnumber or i.id = :cardnumber2)
