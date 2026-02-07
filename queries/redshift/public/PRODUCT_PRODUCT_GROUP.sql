SELECT
    ppgl.PRODUCT_CENTER||'prod'||ppgl.PRODUCT_ID AS "PRODUCT_ID",
    ppgl.PRODUCT_GROUP_ID                        AS "PRODUCT_GROUP_ID",
    pr.LAST_MODIFIED                             AS "ETS"
FROM
    PRODUCT_AND_PRODUCT_GROUP_LINK ppgl
JOIN
    PRODUCTS pr
ON
    pr.center = ppgl.PRODUCT_CENTER
    AND pr.id = ppgl.PRODUCT_ID