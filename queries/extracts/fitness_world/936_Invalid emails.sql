-- The extract is extracted from Exerp on 2026-02-08
--  
select 
PA.txtvalue as email, 
p.firstname || ' ' || p.lastname as name
from 
eclub2.PERSONS P, 
eclub2.PERSON_EXT_ATTRS PA 
where 
PA.personcenter = P.center and 
PA.personid=P.id and
PA.NAME='_eClub_Email' and 
PA.TXTVALUE not like '%@%.%' and
PA.TXTVALUE not like '%.%@%.%'