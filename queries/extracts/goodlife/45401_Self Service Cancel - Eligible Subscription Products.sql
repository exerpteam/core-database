-- The extract is extracted from Exerp on 2026-02-08
-- Created For: MemApps team to check Exerp config for cancel and use list to update blob, see MemApps-283
Created By: Jason Simard	
Date Added: 
select distinct(p.globalid)
from products p
join product_and_product_group_link ppgl on ppgl.product_center = p.center and ppgl.product_id = p.id
join masterproductregister mpr on mpr.globalid = p.globalid
where ppgl.product_group_id = 11201
and mpr.state = 'ACTIVE'
order by p.globalid