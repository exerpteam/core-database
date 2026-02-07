select
c.name as centername,
c.id as centerid,
br.name as resourcename,
brg.name as resourcegroup,
brc.maximum_participations, 
br.attendable, 
br.show_calendar,
br.state,
br.type,
br.external_id
from booking_resources br
join centers c on br.center = c.id
join booking_resource_configs brc on brc.booking_resource_center = br.center and brc.booking_resource_id = br.id 
join booking_resource_groups brg on brg.id = brc.group_id
ORDER BY c.name ASC