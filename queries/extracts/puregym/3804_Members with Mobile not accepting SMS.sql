-- The extract is extracted from Exerp on 2026-02-08
--  
select 
p.center, p.id, ext.txtvalue, ext_accept_email.txtvalue  
from PUREGYM.PERSONS p

join PUREGYM.PERSON_EXT_ATTRS ext
on p.CENTER = ext.PERSONCENTER
and p.ID = ext.PERSONID
and ext.NAME = '_eClub_PhoneSMS'
and ext.TXTVALUE is not null

left join PUREGYM.PERSON_EXT_ATTRS ext_accept_email
on p.CENTER = ext_accept_email.PERSONCENTER
and p.ID = ext_accept_email.PERSONID
and ext_accept_email.NAME = '_eClub_AllowedChannelSMS'
and ext_accept_email.TXTVALUE = 'true'


where
p.STATUS in (1,3)
and p.sex != 'C'
and ext_accept_email.TXTVALUE is null
and p.center in (:scope)