-- The extract is extracted from Exerp on 2026-02-08
--  
SELECT 
p.FIRSTNAME as "First Name",
p.LASTNAME as "Last Name",
pem.txtvalue as "email",
pep.txtvalue as "Telephone",
p.CENTER ||'p'|| p.ID as "Member Number",
p.EXTERNAL_ID AS "Exerp ID"

FROM PERSONS p

join person_ext_attrs pem on pem.personcenter = p.center and pem.personid = p.id and pem.name = '_eClub_Email'

join
person_ext_attrs pep on pep.personcenter = p.center and pep.personid = p.id and pep.name = '_eClub_PhoneSMS'

where 
(p.CENTER) in ($$scope$$)

-- and

-- active members(p.STATUS) in (1,3)
-- (p.STATUS) in (2)