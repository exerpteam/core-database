-- This is the version from 2026-02-05
--  
select
--p.center ||'p'|| p.id as memberid, 
    s.owner_center||'p'||s.owner_id as member, 
    --sp.employee_center||'emp'||sp.employee_id as employee,
    longtodate(SP.entry_time) as entry_time,
    s.START_DATE,
    s.SUBSCRIPTION_PRICE as currentprice,
    sp.from_date, 
    sp.to_date,
    sp.price,
   -- sp.type,
    sp.applied
from 
    subscription_price sp
join
    subscriptions s
    on
    sp.subscription_center = s.center
    and sp.subscription_id = s.id
join persons p
on s.owner_center = p.center and s.owner_id = p.id
where
    sp.from_date >= :date_from 
	and sp.from_date <= :date_to
order by
    s.owner_center
