SELECT
	mp.id,
	mp.cached_productname,
	scopes.name,	
	mp.cached_productprice,
	mp.cached_external_id,
	mp.sales_commission,
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
JOIN
	areas scopes
ON
	mp.scope_id = scopes.id
WHERE 
	mp.cached_producttype = '1'
AND
	mp.state = 'ACTIVE'
ORDER BY mp.cached_productname, scopes.id ASC;