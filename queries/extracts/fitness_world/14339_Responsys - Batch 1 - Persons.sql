-- The extract is extracted from Exerp on 2026-02-08
--  
select 
p.center || 'p' || p.id MemberNo,
p.FIRSTNAME,
p.LASTNAME,
pea_email.txtvalue as Email,
p.center HomeCenter,
p.sex as Gender,
to_char(p.BIRTHDATE, 'YYYY-MM-DD') as Birthdate

from persons p 
left join PERSON_EXT_ATTRS pea_email on pea_email.PERSONCENTER = p.center and pea_email.PERSONID = p.id and pea_email.NAME = '_eClub_Email'
where p.center in (:scope) and p.status in (1,3) and p.sex != 'C' and p.PERSONTYPE != 2 and p.center not in (100)