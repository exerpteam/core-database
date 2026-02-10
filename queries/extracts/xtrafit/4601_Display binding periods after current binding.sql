-- The extract is extracted from Exerp on 2026-02-08
-- EC-7065
Select distinct
        t2.subscription_id,
        t2.SUBSCRIPTION_STATE,
        t2.SUBSCRIPTION_SUB_STATE,
        t2.subscriptiontype_center,
        t2.subscriptiontype_id,
        t2.subscription_price,
        t2.start_date,
        t2.end_date,
        t2.owner_center,
        t2.owner_id,
        t2.external_id,
        t2.binding_end_date,
        case 
        when t2.autoextendmonths = 'months'
        then t2.binding_end_date +( interval '1 months' * cast(t2.autoextendperiod as integer)) 
        else t2.binding_end_date + cast(t2.autoextendperiod as integer) end as binding_end_date_next,
        t2.billed_until_date,
        t2.cached_productname, 
        t2.globalId, 
        cast(t2.autoextendperiod as integer)||' ' ||t2.autoextendmonths as autoextendsetting,
       cast(t2.renewalcount as integer) ||' '|| t2.autoextendrenewalperiod as autoextendrenewalperiod



from
(
WITH pmp_xml AS (
        SELECT m.id, CAST(convert_from(m.product, 'UTF-8') AS XML) AS pxml FROM masterproductregister m 
)
SELECT 
        s.center ||'ss'|| s.id as subscription_id,
        CASE s.STATE WHEN 2 THEN 'ACTIVE' WHEN 3 THEN 'ENDED' WHEN 4 THEN 'FROZEN' WHEN 7 THEN 'WINDOW' WHEN 8 THEN 'CREATED' ELSE 'Undefined' END AS SUBSCRIPTION_STATE,
        CASE s.SUB_STATE WHEN 1 THEN 'NONE' WHEN 2 THEN 'AWAITING_ACTIVATION' WHEN 3 THEN 'UPGRADED' WHEN 4 THEN 'DOWNGRADED' WHEN 5 THEN 'EXTENDED' WHEN 6 THEN 'TRANSFERRED' WHEN 7 THEN 'REGRETTED' WHEN 8 THEN 'CANCELLED' WHEN 9 THEN 'BLOCKED' WHEN 10 THEN 'CHANGED' ELSE 'Undefined' END AS SUBSCRIPTION_SUB_STATE,
        s.subscriptiontype_center,
        s.subscriptiontype_id,
        s.subscription_price,
        s.start_date,
        s.end_date,
        s.owner_center,
        s.owner_id,
        p.external_id,
        s.binding_end_date,
        s.billed_until_date,
        t1.cached_productname, 
        t1.globalId, 
        cast(t1.autoextendperiod as text),
        cast(t1.autoextendmonths as text),
       cast(t1.renewalcount as text),
        cast(t1.autoextendrenewalperiod as text)
       
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
                UNNEST(xpath('//subscriptionType/product/externalId/text()', pmp_xml.pxml)) AS externalId,
                --UNNEST(xpath('//subscriptionType/product/state/text()', pmp_xml.pxml))  as state_t1,
                UNNEST(xpath('//subscriptionType/billingPeriod/period/@unit', pmp_xml.pxml))  as billingPeriodUnit,
                UNNEST(xpath('//subscriptionType/billingPeriod/period/text()', pmp_xml.pxml))  as billingPeriodCount,
                UNNEST(xpath('//subscriptionType/rank/text()', pmp_xml.pxml))  as rank_t1,
                UNNEST(xpath('//subscriptionType/isAddOnSubscription/text()', pmp_xml.pxml))  as requiresMain,
                m2.mapi_description,
                UNNEST(xpath('//subscriptionType/product/privilegeNeeded/text()', pmp_xml.pxml)) AS productRequiresPrivilege,
                 UNNEST(xpath('//subscriptionType/initialPeriod/bindingExtend/text()', pmp_xml.pxml)) AS bindingextend,
                 UNNEST(xpath('//subscriptionType/autoRenewBindingPeriodLength/period/@unit', pmp_xml.pxml)) AS autoextendmonths,
                 UNNEST(xpath('//subscriptionType/autoRenewBindingPeriodLength/period/text()', pmp_xml.pxml)) AS autoextendperiod,
                  UNNEST(xpath('//subscriptionType/autoRenewBindingPeriodNotice/period/@unit', pmp_xml.pxml)) AS autoextendrenewalperiod,
                 UNNEST(xpath('//subscriptionType/autoRenewBindingPeriodNotice/period/text()', pmp_xml.pxml)) AS renewalcount,
                UNNEST(xpath('//subscriptionType/product/showOnWeb/text()', pmp_xml.pxml)) AS showonWeb,
                UNNEST(xpath('//subscriptionType/subscriptionNew/product/maxBuy/@qty', pmp_xml.pxml)) AS purchaseFrequencyMaxBuy,
                UNNEST(xpath('//subscriptionType/subscriptionNew/product/maxBuy/period/@unit', pmp_xml.pxml)) AS purchaseFrequencyPeriodUnit,
                UNNEST(xpath('//subscriptionType/subscriptionNew/product/maxBuy/period/text()', pmp_xml.pxml)) AS purchaseFrequencyPeriod,
                (CASE
	    	        WHEN m2.cached_producttype=1 THEN 'Goods'
			WHEN m2.cached_producttype=2 THEN 'Service'
			WHEN m2.cached_producttype=4 THEN 'Clipcard'
			WHEN m2.cached_producttype=10 THEN 'Subscription'
			WHEN m2.cached_producttype=14 THEN 'Access Product'
			ELSE 'Unknown'	
		END) as productType,
		UNNEST(xpath('//subscriptionType/product/assignedStaffGroup/text()', pmp_xml.pxml)) AS assignedStaffGroups_t1,
                m2.state AS mprState
        FROM 
                pmp_xml, masterproductregister m2 
        WHERE m2.id = pmp_xml.id
              AND m2.cached_producttype = 10
) t1


JOIN products pr
on
pr.globalid = t1.globalid


JOIN SUBSCRIPTIONTYPES st
ON
    st.center = pr.center
    AND st.id = pr.id   


JOIN subscriptions s
ON
    s.subscriptiontype_center = st.center
    AND s.subscriptiontype_id = st.id 
    and s.state in (2,4,8)
join persons p
on
s.owner_center = p.center
and
s.owner_id = p.id    



WHERE  
        CAST(t1.subType AS text) in ('eft','cash')
       and  s.center in (:center))t2