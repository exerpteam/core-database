-- This is the version from 2026-02-05
-- https://clublead.atlassian.net/browse/EC-7700
WITH pmp_xml AS 
(
        SELECT 
                m.id, 
                CAST(convert_from(m.product, 'UTF-8') AS XML) AS pxml 
        FROM masterproductregister m 
        WHERE
                m.cached_producttype = 10
) 
SELECT
        mpr.id AS master_product_id,
        (CASE mpr.scope_type
                WHEN 'A' THEN a.name
                WHEN 'C' THEN c.shortname
                WHEN 'T' THEN 'System'
                ELSE 'Unknown'
        END) AS scope_name_config,
        mpr.globalid,
        mpr.cached_productname AS productname,
        mpr.state,
        CAST(UNNEST(xpath('//subscriptionType/product/prices/price/@start', pmp_xml.pxml)) AS TEXT) AS pricestart,
        UNNEST(xpath('//subscriptionType/product/prices/price/normalPrice/text()', pmp_xml.pxml)) AS normalprice
FROM pmp_xml
JOIN masterproductregister mpr
        ON mpr.id = pmp_xml.id
LEFT JOIN fw.areas a
        ON mpr.scope_type = 'A' AND mpr.scope_id = a.id
LEFT JOIN fw.centers c
        ON mpr.scope_type = 'C' AND mpr.scope_id = c.id
WHERE
        mpr.globalid NOT IN ('14DAYS_FREE_TRIAL','14DAYS_SPONSORED_TRIAL','1_MONTH_FREE_COVID','ACCESS_GATES',
                             'VOUCHER_1M','VOUCHER_2W','VOUCHER_2W_AUTUMN_2014','VOUCHER_2W_CHRISTMAS_2014','EFT_SPECIAL_VOUCHER_1M','EFT_SPECIAL_VOUCHER_2M','EFT_SPECIAL_VOUCHER_3M','EFT_SPECIAL_FDK_VOUCHER',
                             'SEPE_BIK_CHAL_VOU_2W','INFL_VOU_2W',
                             'EFT_STAFF_SOLARIUM','SYS_EFT_STAFF','STAFF','EFT_STAFF_HEAT_WAVE','EFT_STAFF_COMBI','STAFF_EFT','EFT_STAFF_SQUASH','EFT_STAFF_BEAUTY_ANGEL','EFT_STAFF')
        --AND (mpr.scope_type, mpr.scope_id) NOT IN (('A',37),('A',33))
ORDER BY 1,6