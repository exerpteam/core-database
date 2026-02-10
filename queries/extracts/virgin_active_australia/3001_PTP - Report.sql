-- The extract is extracted from Exerp on 2026-02-08
--  
select 
    p.center || 'p' || p.id as MemberID,
    longtodateC(i.trans_time,i.center)::date as Date,
    --p.fullname as MemberName,
    regexp_replace(i.text, '^(Shop sale:|Web sale:|Account sale:)\s*', '', 'i') as Name
from persons p
join invoices i 
    on i.center = p.center 
   and i.payer_id = p.id
where i.text ILIKE '%PT - Kickstart Promo%'
and i.center IN (:center)