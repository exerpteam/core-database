-- The extract is extracted from Exerp on 2026-02-08
--  
SELECT
    mpr.id,
    mpr.globalid,
    mpr.scope_type,
    mpr.scope_id,
    pac.name  AS product_account_config_name,
    pac.scope_type as product_account_scope_type,
    pac2.name AS creation_account_config_name,
    pac2.scope_type AS creation_account_scope_type
FROM
    puregym_arabia.masterproductregister mpr
LEFT JOIN
    puregym_arabia.product_account_configurations pac2
ON
    pac2.id = mpr.creation_account_config_id
LEFT JOIN
    puregym_arabia.product_account_configurations pac
ON
    pac.id = mpr.product_account_config_id