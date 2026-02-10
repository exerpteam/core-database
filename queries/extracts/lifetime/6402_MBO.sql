-- The extract is extracted from Exerp on 2026-02-08
--  
select pea.personcenter||'p'||pea.personid as personid,* from person_ext_attrs pea where 
--pea.name = '_eClub_Email' and 
txtvalue = 'tprintup@ltfinc.net'