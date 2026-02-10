-- The extract is extracted from Exerp on 2026-02-08
--  
select  
    r.relativecenter||'p'||r.relativeid as company,
    r.relativecenter||'p'||r.relativeid||'rpt'||r.relativesubid as agreement,
    p.center||'p'||p.id as customer,
    s.start_date as subscription_start,
    max(longtodate(stl2.entry_start_time)) as start_company_agr
from 
    fw.subscriptions s
join fw.relatives r 
    on
        s.owner_id = r.id
    and s.owner_center = r.center
    and r.rtype = 3 
    and r.status <> 3
join fw.persons p
    on
        s.owner_center = p.center 
    and s.owner_id = p.id       
    and p.persontype = 4
join fw.state_change_log stl
    on
        s.owner_center = stl.center
    and s.owner_id = stl.id
    and stl.entry_type = 3 
    and stl.stateid = 4  
join fw.state_change_log stl2
    on
        p.center = stl2.center
    and p.id = stl2.id
    and stl2.entry_type = 4
    and stl2.stateid = 1
    and stl2.subid = r.subid
where
    r.relativecenter = :Agreement_center
and r.relativeid = :Agreement_id
and r.relativesubid = :Agreement_subid
and stl.entry_start_time < (:toDate)
and stl2.entry_start_time < (:toDate)
and s.state in (2,4,7) --active,frozen, window
GROUP BY 
    r.relativecenter, 
    r.relativeid, 
    r.relativesubid, 
    p.center, 
    p.id,
    s.start_date

MINUS

select  
    r.relativecenter||'p'||r.relativeid as company,
    r.relativecenter||'p'||r.relativeid||'rpt'||r.relativesubid as agreement,
    p.center||'p'||p.id as customer,
    s.start_date as subscription_start,
    max(longtodate(stl2.entry_start_time)) as start_company_agr
from 
    fw.subscriptions s
join fw.relatives r 
    on
        s.owner_id = r.id
    and s.owner_center = r.center
    and r.rtype = 3 
    and r.status <> 3
join fw.persons p
    on
        s.owner_center = p.center 
    and s.owner_id = p.id       
    and p.persontype = 4
join fw.checkins c
    on 
        p.center = c.person_center
    and p.id = c.person_id
join fw.state_change_log stl
    on
        s.owner_center = stl.center
    and s.owner_id = stl.id
    and stl.entry_type = 3 
    and stl.stateid = 4  
join fw.state_change_log stl2
    on
        p.center = stl2.center
    and p.id = stl2.id
    and stl2.entry_type = 4
    and stl2.stateid = 1
    and stl2.subid = r.subid
where
    r.relativecenter = :Agreement_center
and r.relativeid = :Agreement_id
and r.relativesubid = :Agreement_subid
and c.checkin_time between :FromDate and :toDate
and s.state in (2,4,7)
GROUP BY 
    r.relativecenter, 
    r.relativeid, 
    r.relativesubid, 
    p.center, 
    p.id,
    s.start_date
