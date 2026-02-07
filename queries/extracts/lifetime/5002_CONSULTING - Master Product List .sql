SELECT
    p1.scope_id AS scope_id,
    p1.scope_type,
    CASE
        WHEN p1.scope_type = 'T'
        THEN 'System level'
        WHEN p1.scope_type = 'A'
        THEN 'Area level'
        WHEN p1.scope_type = 'C'
        THEN 'Center level'
        ELSE 'Other'
    END                         AS p_scope_type,
    p1.globalid                 AS product_global_id,
    p1.cached_productname       AS product_name,
    p1.primary_product_group_id AS product_group_id,
    pg1.name                    AS product_group_name
FROM
    masterproductregister p1
JOIN
    product_group pg1
ON
    p1.primary_product_group_id = pg1.id
WHERE
    p1.globally_blocked = 'false'
AND p1.state = 'ACTIVE'
AND p1.globalid LIKE :GlobalID
AND p1.cached_producttype = 10 -- Subscription