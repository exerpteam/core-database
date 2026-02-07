SELECT DISTINCT
    prod.name AS add_on_name,
	sa.ADDON_PRODUCT_ID
FROM
	SUBSCRIPTION_ADDON sa
left JOIN masterproductregister m
ON
    sa.addon_product_id = m.id
LEFT JOIN products prod
ON m.globalid = prod.globalid