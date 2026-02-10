-- The extract is extracted from Exerp on 2026-02-08
--  
select
c.id,
c.shortname,
c.name

from 

centers c

where 
c.id IN ($$scope$$)