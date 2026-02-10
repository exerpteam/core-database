-- The extract is extracted from Exerp on 2026-02-08
--  
Select distinct
p.center ||'p'||p.id as Memberid,
p.fullname,
email.TXTVALUE         as        "e-mail",
--spp.from_date,
--spp.to_date,
s.start_date,
s.end_date

from Persons p

join subscriptions s

on
s.owner_center = p.center
and
s.owner_id = p.id

join subscriptionperiodparts spp
on
spp.center = s.center
and 
spp.id = s.id

LEFT JOIN
    PERSON_EXT_ATTRS email
ON
    email.PERSONCENTER=p.center
    AND email.PERSONID=p.id
    AND email.name='_eClub_Email'


where 
p.status in (1,3)
and
(spp.from_date between (:fromdate) and (:todate))
and  
(spp.to_date between (:fromdate) and (:todate))
and p.persontype not in (2)
and s.SUB_STATE not in (8)