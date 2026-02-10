-- The extract is extracted from Exerp on 2026-02-08
--  
SELECT
    p1.center              AS product_center,
    p1.id                  AS product_id,
    p1.center||'pr'||p1.id AS p_product_id,
    p1.globalid            AS product_global_id,
    p1.name                AS product_name,
    pg1.id                 AS product_group_id,
    pg1.name               AS product_group_name
FROM
    products p1
JOIN
    product_group pg1
ON
    p1.primary_product_group_id = pg1.id
WHERE
    p1.blocked = 'false'
AND p1.globalid = :GlobalID
AND p1.ptype = 10 -- Subscription