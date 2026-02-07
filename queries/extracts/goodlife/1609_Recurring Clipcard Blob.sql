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
        t1.subType,
        t1.mprState as "State",
        t1.bindingPeriodCount,
        t1.billingPeriodUnit,
        t1.BillingPeriodCount,
        t1.initialPeriod,
        t1.rank_t1 as "Rank",
        t1.requiresPrivileges,
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
        t1.recurring_clipcard_clips as recurringClipcardClips,
        t1.productType,
        sg.name AS assignedStaffGroups,
		t1.sale_startup_clipcard               
FROM
(
        SELECT  
                m2.id,
                m2.scope_type, 
                m2.scope_id, 
                m2.cached_productname, 
                m2.globalId, 
                m2.cached_productprice,
				m2.sale_startup_clipcard,
                UNNEST(xpath('//subscriptionType/@type', pmp_xml.pxml)) AS subType,
                --UNNEST(xpath('//subscriptionType/subscriptionNew/product/state/text()', pmp_xml.pxml)) AS state_t1,
                UNNEST(xpath('//subscriptionType/bindingPeriod/period/text()', pmp_xml.pxml)) AS bindingPeriodCount,
                UNNEST(xpath('//subscriptionType/billingPeriod/period/@unit', pmp_xml.pxml)) AS billingPeriodUnit,
                UNNEST(xpath('//subscriptionType/billingPeriod/period/text()', pmp_xml.pxml)) AS billingPeriodCount,
                UNNEST(xpath('//subscriptionType/billingPeriod/period/text()', pmp_xml.pxml)) AS initialPeriod,
                UNNEST(xpath('//subscriptionType/rank/text()', pmp_xml.pxml))  AS rank_t1,
                (CASE
                        WHEN (xmlexists('//subscriptionType/subscriptionNew/product/privilegeNeeded/text()' PASSING BY REF pmp_xml.pxml)) THEN
                                UNNEST(xpath('//subscriptionType/subscriptionNew/product/privilegeNeeded/text()', pmp_xml.pxml))       
                        ELSE
                                NULL
                END) AS requiresPrivileges,
                (CASE
                        WHEN (xmlexists('//subscriptionType/freeze/FREEZELIMIT/@MAXFREEZES' PASSING BY REF pmp_xml.pxml)) THEN
                                UNNEST(xpath('//subscriptionType/freeze/FREEZELIMIT/@MAXFREEZES', pmp_xml.pxml))       
                        ELSE
                                NULL
                END) AS freezes_maxfreezes,
                (CASE
                        WHEN (xmlexists('//subscriptionType/freeze/FREEZELIMIT/@MINDURATION' PASSING BY REF pmp_xml.pxml)) THEN
                                UNNEST(xpath('//subscriptionType/freeze/FREEZELIMIT/@MINDURATION', pmp_xml.pxml))       
                        ELSE
                                NULL
                END) AS freezes_minduration,
                (CASE
                        WHEN (xmlexists('//subscriptionType/freeze/FREEZELIMIT/@MINDURATION_UNIT' PASSING BY REF pmp_xml.pxml)) THEN
                                UNNEST(xpath('//subscriptionType/freeze/FREEZELIMIT/@MINDURATION_UNIT', pmp_xml.pxml))       
                        ELSE
                                NULL
                END) AS freezes_minduration_unit,
                (CASE
                        WHEN (xmlexists('//subscriptionType/freeze/FREEZELIMIT/@MAXDURATION' PASSING BY REF pmp_xml.pxml)) THEN
                                UNNEST(xpath('//subscriptionType/freeze/FREEZELIMIT/@MAXDURATION', pmp_xml.pxml))       
                        ELSE
                                NULL
                END) AS freezes_maxduration,
                (CASE
                        WHEN (xmlexists('//subscriptionType/freeze/FREEZELIMIT/@MAXDURATION_UNIT' PASSING BY REF pmp_xml.pxml)) THEN
                                UNNEST(xpath('//subscriptionType/freeze/FREEZELIMIT/@MAXDURATION_UNIT', pmp_xml.pxml))       
                        ELSE
                                NULL
                END) AS freezes_maxduration_unit,
                m2.mapi_description,
                UNNEST(xpath('//subscriptionType/billingPeriod/period/@unit', pmp_xml.pxml)) AS bindingInterval,
		UNNEST(xpath('//subscriptionType/subscriptionNew/product/showOnWeb/text()', pmp_xml.pxml)) AS showonWeb,
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
                m2.recurring_clipcard_clips,
		(CASE
	    	        WHEN m2.cached_producttype=1 THEN 'Goods'
			WHEN m2.cached_producttype=2 THEN 'Service'
			WHEN m2.cached_producttype=4 THEN 'Clipcard'
			WHEN m2.cached_producttype=10 THEN 'Subscription'
			WHEN m2.cached_producttype=14 THEN 'Access Product'
			ELSE 'Unknown'	
		END) as productType,
                (CASE
                        WHEN (xmlexists('//subscriptionType/subscriptionNew/product/assignedStaffGroup/text()' PASSING BY REF pmp_xml.pxml)) THEN
                                UNNEST(xpath('//subscriptionType/subscriptionNew/product/assignedStaffGroup/text()', pmp_xml.pxml))
                        ELSE
                                NULL
                END) AS assignedStaffGroups_t1,
                m2.state AS mprState
        FROM 
                pmp_xml, goodlife.masterproductregister m2 
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
        CAST(t1.subType AS text) = 'clipcard'