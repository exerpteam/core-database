-- The extract is extracted from Exerp on 2026-02-08
--  
SELECT
    p.id AS "Product ID",
    p.name AS "Product Name",
    p.center AS "Product Center",
    c.shortname AS "Club Name",
    p.external_id AS "Product External ID"
FROM
    products p
JOIN
    centers c
    ON c.id = p.center
WHERE
    p.center = 305
    AND NOT EXISTS (
        SELECT 1
        FROM product_and_product_group_link pgp
        WHERE pgp.product_id = p.id
          AND pgp.product_center = p.center
          AND pgp.product_group_id = 4602
    )
ORDER BY
    p.name;
