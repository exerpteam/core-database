WITH pmp_xml AS (
SELECT m.id, CAST(convert_from(m.product, 'UTF-8') AS XML) AS pxml FROM goodlife.masterproductregister m 
)

SELECT 
        t1.id,
        t1.scope_type,
        t1.scope_id, 
        t1.cached_productname, 
        t1.globalId, 
        t1.cached_productprice, 
        t1.sales_units, 
        t1.use_contract_template, 
        t1.sales_commission,
        t1.clipCount,
        t1.expiry,
        t1.expiryUnit,
        t1.requiresPrivileges,
        t1.buyoutFeePercentage,
        t1.showonWeb,
        t1.purchaseFrequencyMaxBuy,
        t1.purchaseFrequencyPeriodUnit,
        t1.purchaseFrequencyPeriod,
        t1.productType,
        r.rolename AS requiredRole,
        sg.name AS assignedStaffGroups
FROM
(
        SELECT  
                m2.id, 
                m2.scope_type, 
                m2.scope_id, 
                m2.cached_productname, 
                m2.globalId, 
                m2.cached_productprice, 
                m2.sales_units, 
                m2.use_contract_template, 
                m2.sales_commission,
                UNNEST(xpath('//clipcardType/clipCount/text()', pmp_xml.pxml)) AS clipCount,
                UNNEST(xpath('//clipcardType/period/text()', pmp_xml.pxml)) AS expiry,
                UNNEST(xpath('//clipcardType/period/@unit', pmp_xml.pxml)) AS expiryUnit,
                UNNEST(xpath('//clipcardType/product/privilegeNeeded/text()', pmp_xml.pxml)) AS requiresPrivileges,
                UNNEST(xpath('//clipcardType/buyoutFeePercentage/text()', pmp_xml.pxml)) AS buyoutFeePercentage,
                UNNEST(xpath('//clipcardType/product/showOnWeb/text()', pmp_xml.pxml)) AS showonWeb,
                UNNEST(xpath('//clipcardType/product/maxBuy/@qty', pmp_xml.pxml)) AS purchaseFrequencyMaxBuy,
                UNNEST(xpath('//clipcardType/product/maxBuy/period/@unit', pmp_xml.pxml)) AS purchaseFrequencyPeriodUnit,
                UNNEST(xpath('//clipcardType/product/maxBuy/period/text()', pmp_xml.pxml)) AS purchaseFrequencyPeriod,
                (CASE
                        WHEN m2.cached_producttype=1 THEN 'Goods'
                        WHEN m2.cached_producttype=2 THEN 'Service'
                        WHEN m2.cached_producttype=4 THEN 'Clipcard'
                        WHEN m2.cached_producttype=10 THEN 'Subscription'
                        WHEN m2.cached_producttype=14 THEN 'Access Product'
                        ELSE 'Unknown'	
                END) as productType,
                UNNEST(xpath('//clipcardType/product/requiredRole/text()', pmp_xml.pxml)) AS requiredRole_t1,
                UNNEST(xpath('//clipcardType/product/assignedStaffGroup/text()', pmp_xml.pxml)) AS assignedStaffGroups_t1
        FROM 
                pmp_xml, goodlife.masterproductregister m2 
        WHERE m2.id = pmp_xml.id
              AND m2.cached_producttype = 4
) t1
LEFT JOIN roles r ON CAST(CAST(t1.requiredRole_t1 AS TEXT) AS INTEGER) = r.id
LEFT JOIN staff_groups sg ON 
        (CASE
                WHEN CAST(t1.assignedStaffGroups_t1 AS TEXT)='null' THEN
                        NULL
                ELSE
                        CAST(CAST(t1.assignedStaffGroups_t1 AS TEXT) AS INTEGER)
         END) = sg.id
