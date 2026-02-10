-- The extract is extracted from Exerp on 2026-02-08
--  
SELECT DISTINCT
    cc.code AS "Campaign Code",
    COALESCE(prg.name, sc.name, 'Unknown Campaign') AS "Campaign Name",
    prod.center || 'prod' || prod.id AS "Product ID",
    prod.name AS "Product Name",
    c.id AS "Centre ID",
    c.name AS "Centre Name",
    CASE 
        WHEN st.st_type = 1 THEN 'EFT Subscription'
        WHEN st.st_type = 2 THEN 'Recurring Clipcard'
        ELSE 'Other'
    END AS "Product Type",
    COUNT(DISTINCT s.center || 'ss' || s.id) AS "Active Subscriptions",
    MIN(s.start_date) AS "First Subscription Date",
    MAX(s.start_date) AS "Last Subscription Date"
FROM 
    campaign_codes cc
-- Join to privilege grants to find what products this campaign applies to
JOIN 
    privilege_grants pg
    ON pg.campaign_code_id = cc.id
JOIN 
    privilege_sets ps
    ON ps.id = pg.privilege_set
JOIN
    privilege_set_products psp
    ON psp.privilege_set_center = ps.center
    AND psp.privilege_set_id = ps.id
-- Get the actual products
JOIN
    products prod
    ON prod.center = psp.product_center
    AND prod.id = psp.product_id
-- Get subscription types to understand the product better
LEFT JOIN
    subscriptiontypes st
    ON st.center = prod.center
    AND st.id = prod.id
-- Get center information
JOIN
    centers c
    ON c.id = prod.center
-- Get campaign information
LEFT JOIN 
    startup_campaign sc 
    ON sc.id = cc.campaign_id 
    AND cc.campaign_type = 'STARTUP'
LEFT JOIN 
    privilege_receiver_groups prg 
    ON prg.id = cc.campaign_id 
    AND cc.campaign_type = 'RECEIVER_GROUP'
-- Optional: Get count of active subscriptions using this product
LEFT JOIN
    subscriptions s
    ON s.subscriptiontype_center = st.center
    AND s.subscriptiontype_id = st.id
    AND s.state IN (2, 4) -- Active and Frozen subscriptions
WHERE
    UPPER(cc.code) = 'FREE21'
    AND prod.center IN (:Scope)
GROUP BY
    cc.code,
    COALESCE(prg.name, sc.name, 'Unknown Campaign'),
    prod.center,
    prod.id,
    prod.name,
    c.id,
    c.name,
    st.st_type
ORDER BY 
    c.name, prod.name