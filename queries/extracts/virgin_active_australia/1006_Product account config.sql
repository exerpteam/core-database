-- The extract is extracted from Exerp on 2026-02-08
--  
SELECT  
        mpr.globalid as Global_ID
        ,mpr.cached_productname	AS Product_name
        ,mpr.state AS product_state	
        ,pac.name AS Account_Config_name	
        ,pac.product_account_type	
        ,pac.sales_account_globalid	
        ,pac.expenses_account_globalid	
        ,pac.refund_account_globalid	
        ,pac.write_off_account_globalid	
        ,pac.defer_rev_account_globalid	
        ,pac.inventory_account_globalid	
        ,pac.defer_lia_account_globalid
FROM
        masterproductregister mpr
JOIN 
        product_account_configurations pac
        ON pac.id = mpr.product_account_config_id