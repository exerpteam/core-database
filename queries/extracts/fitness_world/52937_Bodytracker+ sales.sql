-- The extract is extracted from Exerp on 2026-02-08
-- INC0038802
SELECT
    prod.name   AS "Addon Name",
    c.shortname AS "Club Name",
	c.id        AS "Club Id",	
	sa.SALES_CENTER_ID,
sa.addon_product_id,
    COUNT(*)    AS "Total Sold"
FROM
    SUBSCRIPTION_ADDON sa
JOIN
    masterproductregister m
ON
    sa.addon_product_id = m.id
JOIN
    subscription_sales ss
ON
    sa.subscription_center = ss.subscription_center
    AND sa.subscription_id= ss.subscription_id
JOIN
    centers c
ON
    c.id = ss.owner_center
JOIN
    products prod
ON
    m.globalid = prod.globalid
    AND prod.CENTER = sa.SUBSCRIPTION_CENTER
WHERE
    ss.owner_center IN ($$scope$$)
    AND ss.sales_date >= $$sales_from_date$$
    AND ss.sales_date <= $$sales_to_date$$
    AND prod.globalid IN ('EXTENDED_BCA__ADGANG_')
GROUP BY
    prod.name,
    c.shortname,
    c.id,
	sa.SALES_CENTER_ID,
sa.addon_product_id
ORDER BY
    2 