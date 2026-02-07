select 
p.center ||'p'|| p.id as Company,
p.fullname as Company_name,
pa.TXTVALUE as mail
from PERSONS p
join PERSON_EXT_ATTRS pa 
on p.CENTER = pa.PERSONCENTER and p.ID = pa.PERSONID and pa.name = '_eClub_Email'
where p.SEX = 'C' and pa.TXTVALUE is not null