-- This is the version from 2026-02-05
--  
SELECT
    prod.name   AS "Addon Name",
    c.shortname AS "Club Name",
	c.id        AS "Club Id",
    sa.SALES_CENTER_ID,
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
    AND ss.sales_date >= trunc(current_timestamp) - 7
    AND ss.sales_date <= trunc(current_timestamp)
    AND prod.globalid IN ('ALL_IN__PERSONALE_',
                          'ALL_IN')
GROUP BY
    prod.name,
    c.shortname,
 sa.SALES_CENTER_ID,
    c.id
ORDER BY
    2
