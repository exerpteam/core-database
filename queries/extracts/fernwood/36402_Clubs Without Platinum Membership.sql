-- Simple diagnostic to check platinum SUBSCRIPTION products by club
-- This focuses only on subscription products, not all product types

SELECT 
    c.id AS "Center ID",
    c.shortname AS "Club Name",
    COUNT(p.id) AS "Total Subscription Products",
    SUM(CASE 
        WHEN LOWER(p.name) LIKE '%platinum%' THEN 1 
        ELSE 0 
    END) AS "Platinum Subscription Count"
FROM 
    centers c
LEFT JOIN products p ON p.center = c.id AND p.blocked = false
LEFT JOIN subscriptiontypes st ON st.center = p.center AND st.id = p.id
WHERE 
    c.id IN (:Scope)
    AND (p.id IS NULL OR st.id IS NOT NULL)  -- Only include subscription products or centers with no products
GROUP BY 
    c.id, c.shortname
ORDER BY 
    c.shortname;