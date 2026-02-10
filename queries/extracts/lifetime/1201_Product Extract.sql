-- The extract is extracted from Exerp on 2026-02-08
-- Contains:
Global ID
Product Name
External ID
SELECT
    mp.globalid AS EXERP_GLOBALID,
    mp.cached_productname AS PRODUCT_NAME,
    mp.cached_external_id AS EXTERNAL_ID,
    CASE
        WHEN mp.cached_producttype = 1
        THEN 'Goods'
        WHEN mp.cached_producttype = 2
        THEN 'Service'
        WHEN mp.cached_producttype = 4
        THEN 'Clipcard'
        WHEN mp.cached_producttype = 10
        THEN 'Subscription'
        ELSE NULL
    END AS PRODUCTTYPE
FROM
    masterproductregister mp
order by producttype,mp.cached_external_id,mp.cached_productname