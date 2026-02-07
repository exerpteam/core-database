-- This is the version from 2026-02-05
--  
select 
p.center || 'p' || p.id MemberNo,
p.FIRSTNAME,
p.LASTNAME,
pea_email.txtvalue as Email,
p.center HomeCenter,
p.sex as Gender,
to_char(p.BIRTHDATE, 'YYYY-MM-DD') as Birthdate,
DECODE (STATUS, 0,'LEAD', 1,'ACTIVE', 2,'INACTIVE', 3,'TEMPORARYINACTIVE', 4,'TRANSFERED', 5,'DUPLICATE', 6,'PROSPECT', 7,'DELETED', 'UNKNOWN') AS Status,
p.ZIPCODE,
nvl(pea_accept_email.txtvalue, 'FALSE') as ReceiveEmail,
nvl(pea_newsletter.txtvalue, 'FALSE') as ReceiveNewsletter,
DECODE ( p.PERSONTYPE, 0,'PRIVATE', 1,'STUDENT', 2,'STAFF', 3,'FRIEND', 4,'CORPORATE', 5,'ONEMANCORPORATE', 6,'FAMILY', 7,'SENIOR', 8,'GUEST',9,'CHILD', 'UNKNOWN') AS PERSONTYPE,
case when pea.TXTVALUE is not null then 'Y' else 'N' end as Transferred,
case when pea.TXTVALUE is not null then pea.TXTVALUE else '' end as TransferredTo,
pea_trdate.TXTVALUE as TransferredDate
from persons p 
left join PERSON_EXT_ATTRS pea_email on pea_email.PERSONCENTER = p.center and pea_email.PERSONID = p.id and pea_email.NAME = '_eClub_Email'
left join PERSON_EXT_ATTRS pea_newsletter on pea_newsletter.PERSONCENTER = p.center and pea_newsletter.PERSONID = p.id and pea_newsletter.NAME = '_eClub_IsAcceptingEmailNewsLetters'
left join PERSON_EXT_ATTRS pea_accept_email on pea_accept_email.PERSONCENTER = p.center and pea_accept_email.PERSONID = p.id and pea_accept_email.NAME = '_eClub_AllowedChannelEmail'
left join PERSON_EXT_ATTRS pea on pea.PERSONCENTER = p.center and pea.PERSONID = p.id and pea.name = '_eClub_TransferredToId'
left join PERSON_EXT_ATTRS pea_trdate on pea_trdate.PERSONCENTER = p.center and pea_trdate.PERSONID = p.id and pea_trdate.name = '_eClub_TransferDate'

where
p.status < 5  
and p.sex != 'C' 
and p.center not in (100)
and p.center in (:scope) 