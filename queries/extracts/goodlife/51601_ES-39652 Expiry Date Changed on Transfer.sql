select 
per.fullname as "Member",
s.owner_center||'p'|| s.owner_id as "Person ID",
s.center||'ss'||s.id as "Subscription ID",
p.name as "Subscription",
tr.center || 'ss'|| tr.id as "Transferred (Old) Subscription",
tr.owner_center ||'p'|| tr.owner_id as "Transferred (Old) Person ID",
s.start_date as "Current Start Date",
s.end_date as "Current End Date",
EXTRACT(YEAR FROM AGE(s.end_date, s.start_date)) AS "Year Difference",
tr.start_date as "Old Start Date",
spp.to_date as "Old End Date"


 from
goodlife.subscriptions s
join persons per
on s.owner_center = per.center 
and s.owner_id = per.id
join goodlife.products p
on s.subscriptiontype_center = p.center and s.subscriptiontype_id = p.id
join goodlife.subscriptions tr
on tr.transferred_center = s.center and tr.transferred_id = s.id
join goodlife.subscriptionperiodparts spp
on tr.center = spp.center and tr.id = spp.id
where
p.globalid IN ('ASSOCIATE_5_YEAR','ASSOCIATE_10_YEAR')
--and tr.end_date <> s.end_date
and s.end_date > CURRENT_DATE
and spp.spp_type = 8 and spp.spp_state= 2