select
    p.fullname  as "Member Name",
    sub.id as "Subscription ID"
from 
    persons p
join
    subscriptions sub 
on  
    p.center = sub.owner_center
and 
    p.id = sub.owner_id
where
    p.center in ($$Scope$$)