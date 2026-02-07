-- This is the version from 2026-02-05
--  
select
    P.CENTER || 'p' || P.ID as NEW_ID,
    PEA.TXTVALUE as OLD_ID,
    P.FIRSTNAME,
    P.LASTNAME,
    s.subscription_price,
    s.sub_comment,
	decode(st.st_type, 0, 'CASH', 1, 'EFT') as sttype
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
join fw.subscriptions s
     on
         p.center = s.owner_center
     and p.id = s.owner_id
join fw.subscriptiontypes st
     on
		s.subscriptiontype_center = st.center
and
		s.subscriptiontype_id = st.id

where 
    CES.OLDENTITYID like 'enj01%'
and CES.WRITERNAME = 'ClubLeadPersonWriter'
and st.st_type=1
order by 
    P.CENTER,
    P.ID