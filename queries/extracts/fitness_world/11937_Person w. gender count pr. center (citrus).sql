-- This is the version from 2026-02-05
--  
select
    count(distinct(p.center||'p'||p.id)) as unique_customer_count,
    p.center as person_center,
	c.name as center_name
from
    fw.persons p
join fw.subscriptions s
    on
    p.center = s.owner_center
    and p.id = s.owner_id
join fw.centers c
	on
	p.center = c.id
where
    s.state in (2,4) -- active or frozen.
and p.persontype <> 2
and p.center in (:scope)
group by
    p.center,
	c.name
    