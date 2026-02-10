-- The extract is extracted from Exerp on 2026-02-08
--  
WITH PAPPostTransfer AS (
SELECT DISTINCT
   
    oldsub.center AS Old_Sub_Center,
    oldsub.id AS Old_Sub_ID,
    newsub.center AS New_Sub_Center,
    newsub.id AS New_Sub_ID,
    sc.effect_date                     AS Transfer_Date,
    fromcenter.id                      AS Originating_Club_Number,
    fromcenter.NAME                    AS Originating_Club_Name,
    tocenter.id                        AS Destination_Club_Number,
    tocenter.NAME                      AS Destination_Club_Name,
    'EFT/PAP'                          AS Subscription_Type,
    pg.name                            AS Primary_Product_Group,
    newsub.subscription_price          AS Billing_Amount_Gross,
    CASE
        WHEN newst.periodunit = 0
        THEN 'BI-Weekly'
        ELSE 'Monthly'
    END AS Billing_Cycle,
	CASE
		WHEN oldsub.renewal_policy_override IN (6,10)
		THEN 'Post-Pay'
		WHEN oldsub.renewal_policy_override = 9
		THEN 'Pre-Pay'
		ELSE 'Unknown'
	END AS Renewal_Policy,
    pd.name AS Product_Name
    ,pac.name AS Product_Account_Configuration
,pac.sales_account_globalid
,a.external_id AS sa_external_id
,pac.refund_account_globalid
,a3.external_id AS r_external_id
,pac.write_off_account_globalid
,a4.external_id AS wo_external_id
,pac.defer_rev_account_globalid
,a5.external_id AS def_external_id


FROM
    subscriptions oldsub
JOIN
    subscription_change sc
ON
    sc.old_subscription_center = oldsub.center
    AND sc.old_subscription_id = oldsub.id
    AND sc.type = 'TRANSFER'
JOIN
    subscriptiontypes oldst
ON
    oldst.center = oldsub.subscriptiontype_center
    AND oldst.id = oldsub.subscriptiontype_id
    AND oldst.st_type = 1
JOIN
    subscriptions newsub
ON
    newsub.center = oldsub.transferred_center
    AND newsub.id = oldsub.transferred_id
JOIN
    subscriptiontypes newst
ON
    newst.center = newsub.subscriptiontype_center
    AND newst.id = newsub.subscriptiontype_id
JOIN
    centers fromcenter
ON
    fromcenter.ID=oldsub.owner_center
JOIN
    centers tocenter
ON
    tocenter.ID=newsub.owner_center
JOIN
    products pd
ON
    pd.center = newst.center
    AND pd.id = newst.id
JOIN
    product_group pg
ON
    pg.id = pd.primary_product_group_id
    
    LEFT JOIN product_account_configurations pac
ON pac.id = pd.product_account_config_id

LEFT JOIN masteraccountregister a
ON pac.sales_account_globalid = a.globalid

LEFT JOIN masteraccountregister a3
ON pac.refund_account_globalid = a3.globalid

LEFT JOIN masteraccountregister a4
ON pac.write_off_account_globalid = a4.globalid

LEFT JOIN masteraccountregister a5
ON pac.defer_rev_account_globalid = a5.globalid
WHERE
    oldsub.sub_state = 6
    AND newsub.center IN ($$Scope$$)
    AND sc.effect_date BETWEEN $$TransferDateFrom$$ and $$TransferDateTo$$
    
)


SELECT DISTINCT

ppt.old_sub_center||'ss'||ppt.old_sub_id AS Old_Subscription_ID
,ppt.new_sub_center||'ss'||ppt.new_sub_id AS New_Susbcription_ID
,ppt.transfer_date
,ppt.originating_club_number
,ppt.originating_club_name
,ppt.destination_club_number
,ppt.destination_club_name
,ppt.subscription_type
,ppt.primary_product_group
,ppt.billing_amount_gross
,ppt.billing_cycle
,ppt.renewal_policy
,ppt.product_name
,ppt.product_account_configuration
,ppt.sales_account_globalid
,ppt.sa_external_id
,ppt.refund_account_globalid
,ppt.r_external_id
,ppt.write_off_account_globalid
,ppt.wo_external_id
,ppt.defer_rev_account_globalid
,ppt.def_external_id

,sp.from_date AS pre_transfer_period_from_date
,sp.to_date AS pre_transfer_period_to_date
,sp2.from_date AS post_transfer_period_from_date
,sp2.to_date AS post_transfer_period_to_date
,sp3.from_date AS original_period_from_date
,sp3.to_date AS original_period_to_date

FROM

PAPPostTransfer ppt

LEFT JOIN subscriptionperiodparts sp
ON ppt.old_sub_center = sp.center
AND ppt.old_sub_id = sp.id
AND sp.from_date <= '2019-07-01'
AND sp.to_date >= '2019-06-30'
AND sp.spp_state = 1
AND sp.spp_type IN (1,3,8,9)

LEFT JOIN subscriptionperiodparts sp2
ON ppt.new_sub_center = sp2.center
AND ppt.new_sub_id = sp2.id
AND sp2.from_date = ppt.transfer_date
-- AND sp2.to_date > '2019-06-30'
AND sp2.spp_state = 1
AND sp2.spp_type IN (1,3,8,9)

LEFT JOIN subscriptionperiodparts sp3
ON ppt.old_sub_center = sp3.center
AND ppt.old_sub_id = sp3.id
AND (sp3.from_date = sp.from_date
OR sp3.from_date <= ppt.transfer_date
     AND sp3.to_date > ppt.transfer_date
)
-- AND sp3.to_date >= '2019-06-30'
AND sp3.spp_state = 2
AND sp3.spp_type IN (1,3,8,9)
