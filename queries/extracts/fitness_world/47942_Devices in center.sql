-- This is the version from 2026-02-05
--  
select
    c.center,
    cen.name,
    c.clientid,
    d.name,
	g.name as GATENAME,
    d.driver,
    c.state as client_state,
    case  d.enabled  when 0 then  'Disabled'  when 1 then 'Enabled' end as device_state,
    convert_from(d.configuration, 'UTF-8') AS configuration
from
     clients c
join devices d
on 
        d.client = c.id 
join centers cen
on  
    c.center = cen.id
join gates g
on d.id = g.device_id
where
    c.center in (:scope)
AND	d.ENABLED = 1
AND	c.state != 'DELETED'
order by
    c.center
