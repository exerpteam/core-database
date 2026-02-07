select distinct(p.globalid)
from products p
join product_and_product_group_link ppgl on ppgl.product_center = p.center and ppgl.product_id = p.id
join masterproductregister mpr on mpr.globalid = p.globalid
where ppgl.product_group_id = 11201
and mpr.state = 'ACTIVE'
order by p.globalid