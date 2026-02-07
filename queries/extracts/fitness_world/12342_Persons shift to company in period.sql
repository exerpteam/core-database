-- This is the version from 2026-02-05
--  
select 
    stl.center||'p'||stl.id as persons,
    longtodate(stl.entry_start_time) as switch_to_company,
    company.lastname as companyName,
    company.center||'p'||company.id as companyID,
    prod.globalid as old_sub,
    prod_now.globalid as sub_after_switch
from 
    fw.persons p
join
    fw.state_change_log stl
    on
    p.center = stl.center
    and p.id = stl.id
join
    fw.subscriptions s
    on
    p.center = s.owner_center
    and p.id = s.owner_id
join
    fw.subscriptiontypes subt_before
    on
    s.subscriptiontype_center = subt_before.center
    and s.subscriptiontype_id = subt_before.id
join
    fw.products prod
    on
    subt_before.center = prod.center
    and subt_before.id = prod.id
join
    fw.journalentries j
    on
    p.center = j.person_center
    and p.id = j.person_id
    and j.jetype = 3 and j.person_subid = 1 
join 
    fw.state_change_log stl2
    on
        s.center = stl2.center
    and s.id     = stl2.id
    and stl2.entry_type = 2 and stl2.stateid = 2
left JOIN 
    fw.RELATIVES companyAgrRel
    ON
        s.owner_center = companyAgrRel.CENTER
    AND s.owner_id = companyAgrRel.ID
    AND companyAgrRel.RTYPE = 3
    and companyAgrRel.STATUS = 1
left JOIN 
    fw.COMPANYAGREEMENTS ca
    ON
    ca.CENTER = companyAgrRel.RELATIVECENTER
    AND ca.ID = companyAgrRel.RELATIVEID
    AND ca.SUBID = companyAgrRel.RELATIVESUBID
left JOIN 
    fw.PERSONS company
    ON
    company.CENTER = ca.CENTER
    AND company.ID = ca.id
    AND company.sex = 'C'
join 
    fw.subscriptions sub_now
    on
    p.center = sub_now.owner_center
    and p.id = sub_now.owner_id
    and sub_now.start_date > longtodate(stl.entry_start_time)
join
    fw.subscriptiontypes subt_now
    on
    sub_now.subscriptiontype_center = subt_now.center
    and sub_now.subscriptiontype_id = subt_now.id
join
    fw.products prod_now
    on
    subt_now.center = prod_now.center
    and subt_now.id = prod_now.id
where
    stl.entry_type = 3
and p.center in (:scope)
and subt_before.st_type = 1 --EFT
and subt_now.st_type = 1 -- EFT
and stl.entry_start_time >= :from_date
and stl.entry_start_time <= :to_date
and to_char(longtodate(stl.entry_start_time),'YYYY-MM-dd') 
    not like 
    to_char(longtodate(j.creation_time),'YYYY-MM-dd') 
and stl.stateid = 4
and (
     (stl.entry_start_time between stl2.ENTRY_START_TIME and
stl2.ENTRY_END_TIME) 
     or 
    (stl2.ENTRY_END_TIME is null and stl2.ENTRY_START_TIME <
stl.ENTRY_START_TIME)
     )
and sub_now.start_date in 
    (select
        min(sub_now2.start_date)
     from
         fw.subscriptions sub_now2
     where
    p.center = sub_now2.owner_center
    and p.id = sub_now2.owner_id
    AND p.center = stl.center
    and p.id = stl.id
    and sub_now2.start_date > longtodate(stl.entry_start_time)
    )
group by
    stl.center,
    stl.id,
    stl.entry_start_time,
    company.lastname,
    company.center,
    company.id,
    prod.globalid,
    prod_now.globalid
