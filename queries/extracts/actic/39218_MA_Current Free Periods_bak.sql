select
    s.owner_center as club_scope,
	c.name,
    s.owner_center||'p'||s.owner_id as customer,
    p.fullname as customer_name,
    s.start_date as subscription_start,
	srp.type,
	srp.state,
    srp.start_date as Free_start,
    srp.end_date as Free_end
from
         persons p
    
join subscriptions s
    on
        p.center = s.owner_center
        and p.id = s.owner_id

Join centers c
ON
p.center = c.id
    
join SUBSCRIPTION_REDUCED_PERIOD srp
    on
        s.center = srp.subscription_center
        and s.id = srp.subscription_id
where
    s.owner_center in (:scope)
    and srp.type LIKE 'FREE_ASSIGNMENT' 
	--AND srp.State LIKE 'Active'
    and to_date(exerpsysdate()) >= srp.start_date
    and to_date(exerpsysdate()) <= srp.end_date +1
order by
    s.owner_center,
    s.owner_id,
    srp.start_date