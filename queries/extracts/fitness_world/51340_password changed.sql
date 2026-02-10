-- The extract is extracted from Exerp on 2026-02-08
--  
SELECT 
p.CENTER ||'p'|| p.id as memberid, 
p.fullname as fullname,
j.name as journalentry,
j.creatorcenter || 'emp' || j.creatorid as "password updater id",
pe.fullname,
longtodate(j.CREATION_TIME) as "ændringsdato"

FROM PERSONS p

join

JOURNALENTRIES j

on
p.id = j.person_id

and

p.center = j.person_center

join
EMPLOYEES e
on
j.creatorcenter = e.center
and
j.creatorid = e.id

join
persons pe
on
e.PERSONCENTER = pe.center
and
e.PERSONID = pe.id

where p.CENTER in (:scope)

and j.name = 'Password was updated'
and pe.fullname NOT LIKE 'Online Salg'
and pe.fullname NOT LIKE p.fullname

and j.CREATION_TIME between :from_date and :to_date
