-- This is the version from 2026-02-05
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
where i.text ILIKE '%sweat towel%' 
   or i.text ILIKE '%yoga towel%'
	or i.text ILIKE '%socks%'
or i.text ILIKE '%boxing%'
or i.text ILIKE '%VA Water%'
or i.text ILIKE '%VA Backpack%'
or i.text ILIKE '%My Muscle Chef%'
or i.text ILIKE '%Powerade%'
or i.text ILIKE '%Mt Franklin%'