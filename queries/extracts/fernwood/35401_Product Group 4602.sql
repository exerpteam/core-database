-- The extract is extracted from Exerp on 2026-02-08
--  
SELECT
    pg.id AS "Product Group ID",
    pg.name AS "Product Group Name",
    p.id AS "Product ID",
    p.name AS "Product Name",
    p.center AS "Product Center",
    c.shortname AS "Club Name",
    p.external_id AS "Product External ID"
FROM
    product_group pg
JOIN
    product_and_product_group_link pgp
    ON pg.id = pgp.product_group_id
JOIN
    products p
    ON p.id = pgp.product_id
    AND p.center = pgp.product_center
JOIN
    centers c
    ON c.id = p.center
WHERE
    pg.id = 4602
    AND pg.state != 'DELETED'
ORDER BY
    c.shortname, p.name;
