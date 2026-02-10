-- The extract is extracted from Exerp on 2026-02-08
--  
WITH params AS MATERIALIZED (
    SELECT
        id AS centerid,
        ((now() AT TIME ZONE 'America/New_York')::date - 1) AS sale_date_et
    FROM centers
    WHERE id IN (:Scope)
)
SELECT
    CASE
        WHEN ss.subscription_center = 101 THEN 'SPR'
        WHEN ss.subscription_center = 102 THEN 'BET'
        ELSE ss.subscription_center::text
    END AS "Center",
    COUNT(*) AS "Primary Member – New Sales (ET Yesterday)"
FROM params
JOIN subscriptions s
    ON params.centerid = s.center
JOIN subscriptiontypes st
    ON s.subscriptiontype_center = st.center
   AND s.subscriptiontype_id = st.id
JOIN products pr
    ON st.center = pr.center
   AND st.id = pr.id
LEFT JOIN product_group pg
    ON pr.primary_product_group_id = pg.id
JOIN subscription_sales ss
    ON s.center = ss.subscription_center
   AND s.id = ss.subscription_id
WHERE
    ss.subscription_center IN (:Scope)
    AND ss.sales_date::date = params.sale_date_et   -- ET-based yesterday
    AND ss.type = 1                                 -- NEW
    AND st.st_type < 2                              -- EFT & Cash only
    AND pg.name = 'Primary Member'                  -- Primary Member only
GROUP BY 1
ORDER BY 1;