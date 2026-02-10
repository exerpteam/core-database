-- The extract is extracted from Exerp on 2026-02-08
--  
select 
    p.center || 'p' || p.id as MemberID,
    longtodateC(i.trans_time,i.center)::date as Date,
    p.fullname as MemberName,
    regexp_replace(i.text, '^(Shop sale:|Web sale:|Account sale:)\s*', '', 'i') as Name
from persons p
join invoices i 
    on i.center = p.center 
   and i.payer_id = p.id
where i.text ILIKE '%Casual%' 
   or i.text ILIKE '%class pass%'

union all

select 
    p.center || 'p' || p.id as MemberID,
    p.first_active_start_date::date as Date,
    p.fullname as MemberName,
    pp.name as Name
from subscriptions s
join persons p
    on s.owner_center = p.center 
   and s.owner_id = p.id
join products pp 
    on pp.center = s.subscriptiontype_center 
   and pp.id = s.subscriptiontype_id
where pp.name IN ('Guest Pass Subscription')

order by Date asc;
