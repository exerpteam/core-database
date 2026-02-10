-- The extract is extracted from Exerp on 2026-02-08
-- Created for: Saved free days report for Jesse G and Diane Conley.  Run at end of each month.  Created by: Brent & Sandra  Date added: July, 2023
WITH RECURSIVE subs (center,id,transferred_center,transferred_id)  AS (

        -- Get original subscription id if transferred to get person id at time of sale

        SELECT

        s.center
        ,s.id
	,s.transferred_center
	,s.transferred_id

        FROM

        subscriptions s

        WHERE

(
	s.saved_free_days IS NOT NULL AND s.saved_free_days != 0
)
OR (
	s.saved_free_months IS NOT NULL AND s.saved_free_months != 0
)


        UNION

        SELECT

        s.center
        ,s.id
        ,s.transferred_center
	,s.transferred_id

        FROM subs su

        JOIN subscriptions s

        ON s.transferred_center = su.center
        AND s.transferred_id = su.id

)

SELECT

pe.center||'p'||pe.id as personid
,pe.external_id
,bi_decode_field('PERSONS', 'STATUS', pe.status) AS person_status
,s.center||'ss'||s.id as subscriptionid
,p.name AS product
,s.subscription_price
,s.saved_free_days
,s.saved_free_months
,(COALESCE(s.saved_free_days,0) + COALESCE(s.saved_free_months,0) * 31) AS total_days
,bi_decode_field('SUBSCRIPTIONS', 'STATE', s.state) AS subscription_state
,bi_decode_field('SUBSCRIPTIONS', 'SUB_STATE', s.sub_state) AS subscription_Substate
,CASE WHEN st.st_type = 0 THEN 'PIF'
WHEN st.periodunit = 0 THEN 'BIWEEKLY'
WHEN st.periodunit = 2 THEN 'MONTHLY'
ELSE 'UNKNOWN'
END AS payment_type
,ROUND(CASE WHEN st.st_type = 0 THEN s.subscription_price / 365
WHEN st.periodunit = 0 THEN s.subscription_price / 14
WHEN st.periodunit = 2 THEN s.subscription_price / 31
ELSE 0.00
END,2 )AS daily_rate
,ROUND(ROUND(CASE WHEN st.st_type = 0 THEN s.subscription_price / 365
WHEN st.periodunit = 0 THEN s.subscription_price / 14
WHEN st.periodunit = 2 THEN s.subscription_price / 31
ELSE 0.00
END,2) * (COALESCE(s.saved_free_days,0) + COALESCE(s.saved_free_months,0) * 31),2) AS free_time_value
,a2.name AS subscription_province
,pac.name AS account_configuration
-- ,avtg.global_id AS tax_type
,vt.orig_rate AS tax_rate
,ROUND(ROUND(CASE WHEN st.st_type = 0 THEN s.subscription_price / 365
WHEN st.periodunit = 0 THEN s.subscription_price / 14
WHEN st.periodunit = 2 THEN s.subscription_price / 31
ELSE 0.00
END,2) * (COALESCE(s.saved_free_days,0) + COALESCE(s.saved_free_months,0) * 31),2) * (1 + vt.orig_rate) AS free_time_value_w_tax



FROM

subs su

JOIN subscriptions s USING (center,id)

JOIN products p
ON s.subscriptiontype_center = p.center
AND s.subscriptiontype_id = p.id

JOIN subscriptiontypes st
ON st.center = p.center
AND st.id = p.id

JOIN persons pe
ON pe.center = s.owner_center
AND pe.id = s.owner_id

JOIN area_centers ac
ON s.center = ac.center

JOIN areas a
ON ac.area = a.id
AND a.root_area = 1 -- System

JOIN areas a2
ON a.parent = a2.id
AND a2.root_area = 1
AND a2.parent = 2 -- Canada

JOIN product_account_configurations pac
ON p.product_account_config_id = pac.id

JOIN accounts acc
ON acc.globalid = pac.sales_account_globalid
AND acc.center = s.center

-- JOIN account_vat_type_group avtg
-- ON avtg.account_center = acc.center
-- AND avtg.account_id = acc.id

JOIN account_vat_type_link avtl
ON avtl.account_vat_type_group_id = acc.account_vat_type_group_id

JOIN vat_types vt
ON vt.center = avtl.vat_type_center
AND vt.id = avtl.vat_type_id

WHERE

((
	s.saved_free_days IS NOT NULL AND s.saved_free_days != 0
)
OR (
	s.saved_free_months IS NOT NULL AND s.saved_free_months != 0
)
)

AND s.transferred_center IS NULL

-- LIMIT 20