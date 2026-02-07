Select
s.owner_center ||'p'|| s.owner_id,
sp.*

from subscriptions s

join subscription_price sp
on
s.center = sp.subscription_center
and
s.id = sp.subscription_id


where
sp.from_date > '2025-01-01' and
(s.owner_center, s.owner_id) in (:memberid)