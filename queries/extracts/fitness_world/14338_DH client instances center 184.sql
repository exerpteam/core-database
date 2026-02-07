-- This is the version from 2026-02-05
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