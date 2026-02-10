-- The extract is extracted from Exerp on 2026-02-08
--  
select distinct s.owner_CENTER || 'p' || s.owner_ID as member,  count (s.id) as NS
from subscriptions s
where s.owner_center in( 179,180,181,182)  and s.state = 2 
group by s.owner_CENTER || 'p' || s.owner_ID , s.state
having count (s.id) = 2