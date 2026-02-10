-- The extract is extracted from Exerp on 2026-02-08
-- Master products, account configs, prices and commission
SELECT
	mp.id
,mp.definition_key
,mp.scope_type
,mp.scope_id
,mp.globalid
,mp.masterproductregistertype
,mp.masterproductgroup
,mp.cached_productname
,mp.cached_productprice
,mp.cached_productcostprice
,mp.cached_producttype
,mp.cached_external_id
,mp.info_text
,mp.clearing_house_restriction
,mp.globally_blocked
,mp.state
,mp.primary_product_group_id
,mp.product_account_config_id
,mp.creation_account_config_id
,mp.prorata_account_config_id
,mp.admin_fee_config_id
,mp.use_contract_template
,mp.contract_template_id
,mp.last_state_change
,mp.last_modified
,mp.mapi_selling_points
,mp.mapi_rank
,mp.mapi_description
,mp.buyout_fee_config_id
,mp.sales_commission
,mp.sales_units
,mp.period_commission
,mp.recurring_clipcard_id
,mp.recurring_clipcard_clips
,mp.print_qr_on_receipt
,mp.has_future_price_change
,mp.sale_startup_clipcard
,mp.buyout_fee_percentage
,mp.single_use
,mp.change_requiredrole,

    ac.name account_config,
    acjoin.name joining_account_config,
    acpro.name prorate_account_config
FROM
    masterproductregister mp
LEFT JOIN
    product_account_configurations ac
ON
    mp.product_account_config_id = ac.id
LEFT JOIN
    product_account_configurations acpro
ON
    mp.prorata_account_config_id = acpro.id
LEFT JOIN
    product_account_configurations acjoin
ON
    mp.creation_account_config_id = acjoin.id
LEFT JOIN
    areas ar
ON
    ar.id = mp.scope_id
    AND ar.types = mp.scope_type