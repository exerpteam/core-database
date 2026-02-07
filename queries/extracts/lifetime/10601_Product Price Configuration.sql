--WITH pmp_xml AS (
--SELECT m.id, CAST(convert_from(m.product, 'UTF-8') AS XML) AS pxml FROM masterproductregister m 
--)
SELECT 
        --UNNEST(xpath('//clipcardType/product/prices/price/@start', pmp_xml.pxml)) AS priceUpdate,
        mpr.id, 
        mpr.scope_type,
        mpr.scope_id,
        (CASE
                WHEN mpr.scope_type = 'A'
                THEN a.name
                ELSE NULL
        END) AS area_name,
        (CASE
                WHEN mpr.scope_type = 'C'
                THEN c.name
                ELSE NULL
        END) AS club_name,
        mpr.globalid,
        (CASE mpr.cached_producttype
                WHEN 4 THEN 'Clipcard'
                WHEN 10 THEN 'Subscription'
                ELSE 'UNKNOWN'
        END) AS Product_type,
        mpr.cached_productprice,
        mpr.cached_productname,
        NULL AS new_price
FROM lifetime.masterproductregister mpr
--JOIN pmp_xml ON mpr.id = pmp_xml.id
LEFT JOIN lifetime.areas a ON mpr.scope_type = 'A' AND mpr.scope_id = a.id
LEFT JOIN lifetime.centers c ON mpr.scope_type = 'C' AND mpr.scope_id = c.id
WHERE
        mpr.state = 'ACTIVE'
        AND mpr.cached_producttype IN (4,10)