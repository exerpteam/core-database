-- The extract is extracted from Exerp on 2026-02-08
-- https://clublead.atlassian.net/browse/ST-11684
SELECT
    p.cached_productname as "Product Name",
    pg.name as "Product Group",
    CASE
        WHEN p.scope_type = 'C'
        THEN 'Center: '||c.name
        WHEN p.scope_type = 'A'
        THEN 'Area: '||a.name
        WHEN p.scope_type = 'T'
        THEN 'System Level'
        ELSE 'Unknown'
    END  AS "Product Availability" ,
    p.cached_productprice AS "Product Price",
    p.cached_external_id AS "Product External ID",
    CASE
        WHEN p.cached_producttype = 4
        THEN 'Clipcard'
        WHEN p.cached_producttype = 10
        THEN 'Subscription'
        WHEN p.cached_producttype = 1
        THEN 'Goods'
        WHEN p.cached_producttype = 8
        THEN 'Gift Card'
        WHEN p.cached_producttype = 12
        THEN 'Subscription pro-rata'
        WHEN p.cached_producttype = 13
        THEN 'Subscription add-on'
        WHEN p.cached_producttype = 14
        THEN 'Access product'
        WHEN p.cached_producttype = 2
        THEN 'Service'
        ELSE 'Unknown'
    END  AS "Product Type"
FROM
    lifetime.masterproductregister p
LEFT JOIN
    lifetime.centers c
ON
    c.id = p.scope_id
AND scope_type = 'C'
LEFT JOIN
    lifetime.areas a
ON
    a.id = p.scope_id
AND scope_type = 'A'
LEFT JOIN
lifetime.product_group pg
ON
    pg.id = p.primary_product_group_id
WHERE
    p.state = 'ACTIVE'