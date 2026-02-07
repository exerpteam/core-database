select
	p.center as person_center,
	c.name as center_name,
    p.center,
	p.id,
    p.fullname as customerName,
    s.start_date as subscriptionStart,
    cc.amount,
DECODE (s.STATE, 2,'ACTIVE', 3,'ENDED', 4,'FROZEN', 7,'WINDOW', 8,'CREATED','UNKNOWN') as subscription_STATE,
	s.binding_end_date
from
     persons p
join subscriptions s
    on
    p.center = s.owner_center
    and p.id = s.owner_id
join
     cashcollectioncases cc
     on
     s.owner_center = cc.personcenter
     and s.owner_id = cc.personid
join
	centers c
	on
	p.center = c.id
where
   p.center in (:scope)
   and s.state in (2,4,7) -- active, frozen, window
   and cc.closed = '0'
group by
	p.center,
	c.name,
	p.id,
    p.fullname,
    s.start_date,
    cc.amount,
	s.STATE,
	s.binding_end_date
having 
    cc.amount >= (:minimum_amount)
order by
    p.center,
    p.id