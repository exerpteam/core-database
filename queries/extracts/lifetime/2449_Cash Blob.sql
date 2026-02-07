WITH pmp_xml AS (
        SELECT m.id, CAST(convert_from(m.product, 'UTF-8') AS XML) AS pxml FROM masterproductregister m 
)
SELECT 
        t1.id, 
        t1.scope_type, 
        t1.scope_id, 
        t1.cached_productname, 
        t1.globalId, 
        t1.cached_productprice,
        t1.subType,
        t1.privilegeNeeded,
        t1.externalId,
        t1.mprState as "State",
        t1.billingPeriodUnit,
        t1.BillingPeriodCount,
        t1.rank_t1 as "Rank",
        t1.requiresMain,
        t1.mapi_description,
        t1.productRequiresPrivilege,
        t1.showonWeb,
        t1.purchaseFrequencyMaxBuy,
        t1.purchaseFrequencyPeriodUnit,
        t1.purchaseFrequencyPeriod,
        t1.productType,
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
                UNNEST(xpath('//subscriptionType/@type', pmp_xml.pxml)) AS subType,
                UNNEST(xpath('//subscriptionType/product/privilegeNeeded/text()', pmp_xml.pxml))  as privilegeNeeded,
                (CASE
                        WHEN (xmlexists('//subscriptionType/product/externalId/text()' PASSING BY REF pmp_xml.pxml)) THEN
                                UNNEST(xpath('//subscriptionType/product/externalId/text()', pmp_xml.pxml))         
                        ELSE
                                NULL
                END) AS externalId,
                --UNNEST(xpath('//subscriptionType/product/state/text()', pmp_xml.pxml))  as state_t1,
                UNNEST(xpath('//subscriptionType/billingPeriod/period/@unit', pmp_xml.pxml))  as billingPeriodUnit,
                UNNEST(xpath('//subscriptionType/billingPeriod/period/text()', pmp_xml.pxml))  as billingPeriodCount,
                UNNEST(xpath('//subscriptionType/rank/text()', pmp_xml.pxml))  as rank_t1,
                UNNEST(xpath('//subscriptionType/isAddOnSubscription/text()', pmp_xml.pxml))  as requiresMain,
                m2.mapi_description,
                UNNEST(xpath('//subscriptionType/product/privilegeNeeded/text()', pmp_xml.pxml)) AS productRequiresPrivilege,
                UNNEST(xpath('//subscriptionType/product/showOnWeb/text()', pmp_xml.pxml)) AS showonWeb,
                (CASE
                        WHEN (xmlexists('//subscriptionType/subscriptionNew/product/maxBuy/@qty' PASSING BY REF pmp_xml.pxml)) THEN
                                UNNEST(xpath('//subscriptionType/subscriptionNew/product/maxBuy/@qty', pmp_xml.pxml))       
                        ELSE
                                NULL
                END) AS purchaseFrequencyMaxBuy,
                (CASE
                        WHEN (xmlexists('//subscriptionType/subscriptionNew/product/maxBuy/period/@unit' PASSING BY REF pmp_xml.pxml)) THEN
                                UNNEST(xpath('//subscriptionType/subscriptionNew/product/maxBuy/period/@unit', pmp_xml.pxml))       
                        ELSE
                                NULL
                END) AS purchaseFrequencyPeriodUnit,
                (CASE
                        WHEN (xmlexists('//subscriptionType/subscriptionNew/product/maxBuy/period/text()' PASSING BY REF pmp_xml.pxml)) THEN
                                UNNEST(xpath('//subscriptionType/subscriptionNew/product/maxBuy/period/text()', pmp_xml.pxml))       
                        ELSE
                                NULL
                END) AS purchaseFrequencyPeriod,
                (CASE
                    WHEN m2.cached_producttype=1 THEN 'Goods'
            WHEN m2.cached_producttype=2 THEN 'Service'
            WHEN m2.cached_producttype=4 THEN 'Clipcard'
            WHEN m2.cached_producttype=10 THEN 'Subscription'
            WHEN m2.cached_producttype=14 THEN 'Access Product'
            ELSE 'Unknown'  
        END) as productType,
        (CASE
                        WHEN (xmlexists('//subscriptionType/product/assignedStaffGroup/text()' PASSING BY REF pmp_xml.pxml)) THEN
                                UNNEST(xpath('//subscriptionType/product/assignedStaffGroup/text()', pmp_xml.pxml))
                        ELSE
                                NULL
                END) AS assignedStaffGroups_t1,
                m2.state AS mprState
        FROM 
                pmp_xml, masterproductregister m2 
        WHERE m2.id = pmp_xml.id
              AND m2.cached_producttype = 10
) t1
LEFT JOIN staff_groups sg ON 
        (CASE
                WHEN CAST(t1.assignedStaffGroups_t1 AS TEXT)='null' THEN
                        NULL
                ELSE
                        CAST(CAST(t1.assignedStaffGroups_t1 AS TEXT) AS INTEGER)
         END) = sg.id
WHERE  
        CAST(t1.subType AS text) = 'cash'