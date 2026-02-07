-- This is the version from 2026-02-05
--  
select
    P.CENTER || 'p' || P.ID as NEW_ID,
    PEA.TXTVALUE as OLD_ID,
    P.FIRSTNAME,
    P.LASTNAME,
    s.subscription_price,
    s.sub_comment
from 
     fw.CONVERTER_ENTITY_STATE CES
join fw.PERSON_EXT_ATTRS PEA 
     on 
        (CES.NEWENTITYCENTER = PEA.PERSONCENTER 
     and CES.NEWENTITYID = PEA.PERSONID 
     and PEA.NAME = '_eClub_OldSystemPersonId')
join fw.PERSONS P 
     on 
        (CES.NEWENTITYCENTER = P.CENTER 
     and CES.NEWENTITYID = P.ID)
left join fw.subscriptions s
     on
         p.center = s.owner_center
     and p.id = s.owner_id
where 
    CES.OLDENTITYID like 'enj02%'
and CES.WRITERNAME = 'ClubLeadPersonWriter'
order by 
    P.CENTER,
    P.ID