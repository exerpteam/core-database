select  
r.relativecenter,
r.relativeid,
r.relativesubid, 
p.center, p.id,   COUNT (distinct c.checkin_time / (24*3600*1000) + TO_DATE('01-01-1970','dd-mm-yyyy '))
as CheckinCount,
CONCAT(CONCAT(p.center,'p' ),p.id) AS PersonId
from subscriptions s, relatives r, checkin_log c, persons p 
where
/* Select all members on a company agreement using its id and the status */
/* (use center=300, id=955, subid=1 for company agreement with id 300p955rpt1)*/
r.relativecenter = :relativecenter
and r.relativeid = :relativeid
and r.relativesubid = :relativesubid
and r.status <> 3
and r.rtype = 3  /* only company agreement relations */
and s.owner_id = r.id
and s.owner_center = r.center
and s.owner_id = p.id
and s.owner_center = p.center
and c.id  = p.id
and c.center = p.center
and p.persontype = 4  /* only corporate */
and c.checkin_time between :fromTime and
:toTime 
GROUP BY r.relativecenter, r.relativeid, r.relativesubid, p.center, p.id
ORDER BY p.center, p.id