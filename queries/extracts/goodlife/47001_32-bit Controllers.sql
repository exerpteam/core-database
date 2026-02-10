-- The extract is extracted from Exerp on 2026-02-08
-- This extract can Identify 32-bit contoler architecture
SELECT DISTINCT
     ON
        (
            ci.client) 
            cen.id as "Center ID",
            cen.shortname as "Center Name",
            ci.ipaddress as "Controller IP",
            ci.macaddress as "Controller MAC",
            ci.hostname as "Controller Host",
            ci.clientversion as "Exerp Version",
            ci.jvm_arch as "JVM Version"
            
   FROM
        goodlife.client_instances ci
   JOIN
        goodlife.clients c
     ON
        ci.client = c.id
        
        join centers cen on c.center = cen.id
        
  WHERE
        c."type" = 'CONTROLLER'
        AND c.state = 'ACTIVE'
        AND ci.jvm_arch = 'X86'