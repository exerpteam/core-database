-- This is the version from 2026-02-05
--  
select
    c.center,
    cen.name,
    c.clientid,
    d.name,
    d.driver,
    c.state as client_state,
    decode (d.enabled, 0, 'Disabled', 1,'Enabled') as device_state,
	utl_raw.cast_to_varchar2(dbms_lob.substr(d.configuration)) as configuration
from
     fw.clients c
join fw.devices d
on 
        d.client = c.id 
    and d.driver like 'dk.procard.eclub.devices.drivers.barionet.BarionetDriver' 
join fw.centers cen
on  
    c.center = cen.id
where
    c.center in (:scope)
order by
    c.center
