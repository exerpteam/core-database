select distinct
prod.external_id, 
     (CASE prod.PTYPE
        WHEN 1 THEN 'Merchandising'
        WHEN 2 THEN 'Service'
        WHEN 4 THEN 'Clipcard'
        WHEN 5 THEN 'Subscription creation'
        WHEN 6 THEN 'Transfer'
        WHEN 7 THEN 'Freeze period'
        WHEN 8 THEN 'Gift card'
        WHEN 9 THEN 'Free gift card'
        WHEN 10 THEN 'Subscription'
        WHEN 12 THEN 'Subscription pro-rata'
        WHEN 13 THEN 'Addon service'
     END) product_type,
prod.name as product_name,
prod.price,
prod.product_account_config_id,
pac.NAME as account_configuration,
sales_acc.EXTERNAL_ID as sales_account
from products prod
 JOIN
     PRODUCT_ACCOUNT_CONFIGURATIONS pac
 ON
     pac.ID = prod.PRODUCT_ACCOUNT_CONFIG_ID
LEFT JOIN
     ACCOUNTS sales_acc
 ON
     sales_acc.GLOBALID = pac.SALES_ACCOUNT_GLOBALID
     and sales_acc.CENTER = prod.CENTER
where 
prod.center in ($$scope$$)
and prod.blocked = 0
AND prod.PTYPE IN (:pType)


