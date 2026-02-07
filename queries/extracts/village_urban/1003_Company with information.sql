select 
p.center ||'p'|| p.id as Company_ID,
p.fullname as Company_name,
pa.TXTVALUE as contact_mail,
pa2.TXTVALUE as Invoice_mail
from PERSONS p
left join PERSON_EXT_ATTRS pa 
on p.CENTER = pa.PERSONCENTER and p.ID = pa.PERSONID and pa.name = '_eClub_Email'


left join PERSON_EXT_ATTRS pa2 
on p.CENTER = pa2.PERSONCENTER and p.ID = pa2.PERSONID and pa2.name = '_eClub_InvoiceEmail'


where p.SEX = 'C'