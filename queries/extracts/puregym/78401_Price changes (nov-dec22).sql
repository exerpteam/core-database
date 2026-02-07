Select
p.center ||'p'|| p.id as personid,
longtodate(entry_time),
from_date,
to_date,
s.billed_until_date,
s.end_date

from subscription_price sp

join subscriptions s
on
sp.subscription_center = s.center
and
sp.subscription_id = s.id

join persons p 
on p.center = s.owner_center 
and p.id = s.owner_id

where 
sp.employee_center = 100
and sp.employee_id = 34402
and sp.entry_time > :timeafter
and sp.cancelled = 'false'
and sp.type != 'TRANSFER'
and p.status in (1,3)
