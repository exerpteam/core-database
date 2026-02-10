-- The extract is extracted from Exerp on 2026-02-08
--  
select p.name, pg.name
from invoice_lines_mt il
         join products p on il.productcenter = p.center and il.productid = p.id
         join product_group pg on p.primary_product_group_id = pg.id
where il.center = 101142
  and il.id = 22188
  and il.subid = 2