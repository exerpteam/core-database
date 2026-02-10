-- The extract is extracted from Exerp on 2026-02-08
--  
select  
   cli.*,
   ci.*
from 
   fw.clients cli
join fw.client_instances ci 
    on 
    ci.client = cli.id 
where 
   cli.center = 184