-- The extract is extracted from Exerp on 2026-02-08
--  
SELECT 
	p.NAME AS ProductName,	
	p.PRICE AS ProductPrice,
	p.COST_PRICE AS CostPrice,
	p.MIN_PRICE AS MinPrice,
	c.NAME AS CenterName,
	p.BLOCKED AS Blocked,
	p.PTYPE AS PType,
	p.SHOW_IN_SALE AS ShowInSale,
	pg.NAME AS ProductGroupName
FROM PRODUCTS p, CENTERS c, PRODUCT_GROUP pg
WHERE
	p.CENTER in (:center) AND
	p.CENTER = c.ID AND	
	pg.ID = p.PRIMARY_PRODUCT_GROUP_ID AND
	p.BLOCKED=0 AND
	p.PTYPE=10
	
ORDER BY p.NAME
--GROUP BY p.NAME, pg.NAME

--select distinct --p.id,p.master_product_id,p2.master_product_id,p.name,p.sales_pric--e, p2.name,p2.sales_price,p.type from Product p,Product p2 where --p.blocked = false and p2.blocked=false and p.center_id = --p2.center_id and p.center= :center and p.master_product_id = --p2.master_product_id/* and p.external_id = p2.external_id */ and --p.type like 'SUBS%' and p2.type like 'JOIN%' --and p.external_id --is not null --group by p.master_product_id,p.id
