WITH pmp_xml AS (
	
	SELECT 
		
        m.id, 
        CAST(convert_from(m.product, 'UTF-8') AS XML) AS pxml 
	
	FROM masterproductregister m 

        WHERE

        m.cached_producttype = 10
	
), creation_product_groups AS (

        SELECT DISTINCT
    
        id
        ,CAST(CAST(UNNEST(xpath('//subscriptionType/subscriptionNew/product/productGroupKeys/productGroupKey/text()', pmp_xml.pxml)) AS TEXT) AS INTEGER) AS CreationProductGroup
	,CAST(CAST(UNNEST(xpath('//subscriptionType/subscriptionNew/product/primaryProductGroupKey/text()', pmp_xml.pxml)) AS TEXT)AS INTEGER) AS CreationPrimaryProductGroup
        ,rank() OVER (PARTITION BY id ORDER BY CAST(CAST(UNNEST(xpath('//subscriptionType/subscriptionNew/product/productGroupKeys/productGroupKey/text()', pmp_xml.pxml)) AS TEXT)AS INTEGER) DESC) AS rank

        FROM
    
        pmp_xml
    
        WHERE

	(xmlexists('//subscriptionType/subscriptionNew/product/productGroupKeys/productGroupKey/text()' PASSING BY REF pmp_xml.pxml))
	
	
), proata_product_groups AS (

        SELECT DISTINCT
    
        id
        ,CAST(CAST(UNNEST(xpath('//subscriptionType/subscriptionProRataPeriod/product/productGroupKeys/productGroupKey/text()', pmp_xml.pxml)) AS TEXT)AS INTEGER) AS ProrataProductGroup
        ,CAST(CAST(UNNEST(xpath('//subscriptionType/subscriptionProRataPeriod/product/primaryProductGroupKey/text()', pmp_xml.pxml)) AS TEXT)AS INTEGER) AS ProrataPrimaryProductGroup
        ,rank() OVER (PARTITION BY id ORDER BY CAST(CAST(UNNEST(xpath('//subscriptionType/subscriptionProRataPeriod/product/productGroupKeys/productGroupKey/text()', pmp_xml.pxml)) AS TEXT)AS INTEGER) DESC) AS rank
    
        FROM
    
        pmp_xml
    
        WHERE
	
        (xmlexists('//subscriptionType/subscriptionProRataPeriod/product/productGroupKeys/productGroupKey/text()' PASSING BY REF pmp_xml.pxml))
    
)

SELECT 

        t1.id,
        t1.scope_type,
        t1.scope_id, 
        t1.cached_productname, 
        t1.globalId, 
        t1.cached_productprice, 
        t1.subType,
        t1.mprState as "State",
        t1.bindingPeriodCount,
        t1.billingPeriodUnit,
        t1.BillingPeriodCount,
        t1.initialPeriod,
        t1.rank_t1 as "Rank",
        t1.requiresPrivileges,
        t1.prorataPeriod,
        t1.freezes_maxfreezes,
        t1.freezes_minduration,
        t1.freezes_minduration_unit,
        t1.freezes_maxduration,
        t1.freezes_maxduration_unit,
        t1.mapi_description,
        t1.bindingInterval,
        t1.showonWeb,
        t1.purchaseFrequencyMaxBuy,
        t1.purchaseFrequencyPeriodUnit,
        t1.purchaseFrequencyPeriod,
        t1.productType,
        sg.name AS assignedStaffGroups,
        
        c1.CreationPrimaryProductGroup,
        c1.CreationProductGroup AS CreationProductGroup1,
        c2.CreationProductGroup AS CreationProductGroup2,
        c3.CreationProductGroup AS CreationProductGroup3,
        c4.CreationProductGroup AS CreationProductGroup4,
        c5.CreationProductGroup AS CreationProductGroup5,
        p1.ProrataPrimaryProductGroup,
        p1.ProrataProductGroup AS ProrataProductGroup1,
        p2.ProrataProductGroup AS ProrataProductGroup2,
        p3.ProrataProductGroup AS ProrataProductGroup3,
        p4.ProrataProductGroup AS ProrataProductGroup4,
        p5.ProrataProductGroup AS ProrataProductGroup5
         
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
        UNNEST(xpath('//subscriptionType/product/state/text()', pmp_xml.pxml)) AS state_t1,
        UNNEST(xpath('//subscriptionType/bindingPeriod/period/text()', pmp_xml.pxml)) AS bindingPeriodCount,
        UNNEST(xpath('//subscriptionType/billingPeriod/period/@unit', pmp_xml.pxml)) AS billingPeriodUnit,
        UNNEST(xpath('//subscriptionType/billingPeriod/period/text()', pmp_xml.pxml)) AS billingPeriodCount,
        UNNEST(xpath('//subscriptionType/billingPeriod/period/text()', pmp_xml.pxml)) AS initialPeriod,
        UNNEST(xpath('//subscriptionType/rank/text()', pmp_xml.pxml))  AS rank_t1,
        UNNEST(xpath('//subscriptionType/product/privilegeNeeded/text()', pmp_xml.pxml))  AS requiresPrivileges,
        UNNEST(xpath('//subscriptionType/prorataPeriod/period/text()', pmp_xml.pxml)) AS prorataPeriod,
        UNNEST(xpath('//subscriptionType/freeze/FREEZELIMIT/@MAXFREEZES', pmp_xml.pxml)) AS freezes_maxfreezes,
        UNNEST(xpath('//subscriptionType/freeze/FREEZELIMIT/@MINDURATION', pmp_xml.pxml)) AS freezes_minduration,
        UNNEST(xpath('//subscriptionType/freeze/FREEZELIMIT/@MINDURATION_UNIT', pmp_xml.pxml)) AS freezes_minduration_unit,
        UNNEST(xpath('//subscriptionType/freeze/FREEZELIMIT/@MAXDURATION', pmp_xml.pxml)) AS freezes_maxduration,
        UNNEST(xpath('//subscriptionType/freeze/FREEZELIMIT/@MAXDURATION_UNIT', pmp_xml.pxml)) AS freezes_maxduration_unit,
        m2.mapi_description,
        UNNEST(xpath('//subscriptionType/billingPeriod/period/@unit', pmp_xml.pxml)) AS bindingInterval,
        UNNEST(xpath('//subscriptionType/product/showOnWeb/text()', pmp_xml.pxml)) AS showonWeb,
        UNNEST(xpath('//subscriptionType/subscriptionNew/product/maxBuy/@qty', pmp_xml.pxml)) AS purchaseFrequencyMaxBuy,
        UNNEST(xpath('//subscriptionType/subscriptionNew/product/maxBuy/period/@unit', pmp_xml.pxml)) AS purchaseFrequencyPeriodUnit,
        UNNEST(xpath('//subscriptionType/subscriptionNew/product/maxBuy/period/text()', pmp_xml.pxml)) AS purchaseFrequencyPeriod,
        CASE
                WHEN m2.cached_producttype=1 THEN 'Goods'
                WHEN m2.cached_producttype=2 THEN 'Service'
                WHEN m2.cached_producttype=4 THEN 'Clipcard'
                WHEN m2.cached_producttype=10 THEN 'Subscription'
                WHEN m2.cached_producttype=14 THEN 'Access Product'
                ELSE 'Unknown'	
        END AS productType,
        UNNEST(xpath('//subscriptionType/product/assignedStaffGroup/text()', pmp_xml.pxml)) AS assignedStaffGroups_t1,
        m2.state AS mprState

        FROM 
                
        masterproductregister m2 

        JOIN pmp_xml
        ON m2.id = pmp_xml.id
        AND m2.cached_producttype = 10

) t1

LEFT JOIN staff_groups sg 
ON (CASE
        WHEN CAST(t1.assignedStaffGroups_t1 AS TEXT)='null' 
        THEN NULL
        ELSE CAST(CAST(t1.assignedStaffGroups_t1 AS TEXT) AS INTEGER)
END) = sg.id

LEFT JOIN creation_product_groups c1
ON t1.id = c1.id
AND c1.rank = 1

LEFT JOIN creation_product_groups c2
ON t1.id = c2.id
AND c2.rank = 2

LEFT JOIN creation_product_groups c3
ON t1.id = c3.id
AND c3.rank = 3

LEFT JOIN creation_product_groups c4
ON t1.id = c4.id
AND c4.rank = 4

LEFT JOIN creation_product_groups c5
ON t1.id = c5.id
AND c5.rank = 5

LEFT JOIN proata_product_groups p1
ON t1.id = p1.id
AND p1.rank = 1

LEFT JOIN proata_product_groups p2
ON t1.id = p2.id
AND p2.rank = 2

LEFT JOIN proata_product_groups p3
ON t1.id = p3.id
AND p3.rank = 3

LEFT JOIN proata_product_groups p4
ON t1.id = p4.id
AND p4.rank = 4

LEFT JOIN proata_product_groups p5
ON t1.id = p5.id
AND p5.rank = 5
     
WHERE  
        
CAST(t1.subType AS text) = 'eft'