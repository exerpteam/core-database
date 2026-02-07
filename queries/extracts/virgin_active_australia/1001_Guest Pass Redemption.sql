-- This is the version from 2026-02-05
--  
select p.center || 'p' || p.id as MemebrID, p.first_active_start_date as GuestPassRedemtpionDate, p.fullname as MemberName,pp.name as SubscriptionName from subscriptions s join persons p
on s.owner_center = p.center and s.owner_id = p.id
join products pp on pp.center = s.subscriptiontype_center and pp.id = s.subscriptiontype_id
and pp.name IN ('Guest Pass Subscription')