select 
scf.id, scf.scope_type || scf.scope_id as "Scope"
, sub_from_mpr.globalid as "Subscription_From"
--, sub_from_mpr.cached_productname as "Subscription_From_Name"
, pg_from.name as "Subscription_From_Group"
, sub_to_mpr.globalid as "Subscription_To" 
--, sub_to_mpr.cached_productname as "Subscription_To_Name"
, pg_to.name as "Subscription_To_Group"
, fee_mpr.globalid as "Change_Fee_Product"
--, fee_mpr.cached_productname as "Change_Fee_Product_Name"
, scf.type as "Type"
, scf.change_fee_percentage as "Change_Fee_Percentage"

from subscription_change_fees scf
left join masterproductregister sub_from_mpr on scf.subscr_type_from = sub_from_mpr.id
left join masterproductregister sub_to_mpr on scf.subscr_type_to = sub_to_mpr.id
left join masterproductregister fee_mpr on scf.change_fee_product = fee_mpr.id
left join product_group pg_from on pg_from.id = sub_from_mpr.primary_product_group_id
left join product_group pg_to on pg_to.id = sub_to_mpr.primary_product_group_id

where scf.state = 'ACTIVE'