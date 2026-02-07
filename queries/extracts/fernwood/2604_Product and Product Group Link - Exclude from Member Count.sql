SELECT  DISTINCT 
        p.name AS "Product Name"
        ,pg.name AS "Product Group"
        ,pg.exclude_from_member_count AS "Exclude From Member Count"
,pg.id
FROM 
        fernwood.products p     
LEFT JOIN 
        fernwood.product_and_product_group_link pgl
        ON pgl.product_center = p.center
        AND pgl.product_id = p.id
LEFT JOIN 
        fernwood.product_group pg
        ON pg.id = pgl.product_group_id                
WHERE
        p.ptype = 10