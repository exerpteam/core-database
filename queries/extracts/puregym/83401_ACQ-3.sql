SELECT
    REPLACE(pr.GLOBALID, 'CREATION_', '') AS "ProductGlobalId",
    pg.id       AS "JoiningFeeGroupId"
FROM
    PRODUCTS pr
JOIN 
    product_and_product_group_link ppgl
    ON ppgl.product_center = pr.center
    AND ppgl.product_id = pr.id
JOIN
    PRODUCT_GROUP pg
ON
    ppgl.product_group_id = pg.ID
WHERE
    pr.PTYPE = 5
AND pr.BLOCKED = 0
AND pr.CENTER IN (:Center)