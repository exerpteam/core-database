-- The extract is extracted from Exerp on 2026-02-08
--  
SELECT
    pg.id AS "PRODUCT_GROUP_ID",
    pg.name AS "PRODUCT_GROUP_NAME",
    a.name AS "SCOPE",
    pg.state AS "PRODUCT_GROUP_STATE",
    pg.external_id AS "PRODUCT_GROUP_EXTERNAL_ID"
FROM
    product_group pg
JOIN
    areas a
ON
    a.id = pg.scope_id
WHERE
    state != 'DELETED'
AND pg.name IS NOT NULL