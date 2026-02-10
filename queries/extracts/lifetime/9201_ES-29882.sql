-- The extract is extracted from Exerp on 2026-02-08
--  
select *--count(*),personcenter||'p'||personid as person_id
from person_ext_attrs p
where --name = '_eClub_Email' and 
txtvalue='e272350@ltfinc.net'
--group by p.personcenter, p.personid
--having count(*)>1
Limit 250;