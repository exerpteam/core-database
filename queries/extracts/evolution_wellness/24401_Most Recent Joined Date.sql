select
	p.center || 'p' || p.id AS PersonId,
	p.external_Id AS ExternalId,
	p.First_Active_Start_date,
	s.start_date AS First_Subscription_Start_date
from 
	persons p
JOIN subscriptions s
	ON s.owner_center = p.center and s.owner_id = p.id
WHERE p.center in (:Scope)
	AND p.Status IN (1,3,9)
Group BY p.center, p.id, p.first_active_start_date, s.Start_date
ORDER BY p.center, p.id, p.first_active_start_date, s.Start_date ASC