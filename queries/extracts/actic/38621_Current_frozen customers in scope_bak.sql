-- The extract is extracted from Exerp on 2026-02-08
-- Backup of Current Frozen customers in scope
select
    s.owner_center as club_scope,
	c.name,
    s.owner_center||'p'||s.owner_id as customer,
    p.fullname as customer_name,
    s.start_date as subscription_start,
    sfp.start_date as freeze_start,
    sfp.end_date as freeze_end,
	to_date(exerpsysdate())
from
         persons p
    join subscriptions s
    on
        p.center = s.owner_center
        and p.id = s.owner_id

Join centers c
ON 
p.center = c.id

    join subscription_freeze_period sfp
    on
        s.center = sfp.subscription_center
        and s.id = sfp.subscription_id
where
    s.owner_center in (:scope)
    and s.state = 4 -- frozen
    and to_date(exerpsysdate()) >= sfp.start_date
    and to_date(exerpsysdate()) <= sfp.end_date +1
order by
    s.owner_center,
    s.owner_id,
    sfp.start_date