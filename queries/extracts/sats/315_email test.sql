select p.id, p.center, p.firstname, p.lastname, pea.txtvalue 

from eclub2.person_ext_attrs pea, eclub2.persons p

where name = '_eClub_Email' 
and p.id = pea.personid
and p.center = pea.personcenter and P.PERSONTYPE IN ( :persontype )