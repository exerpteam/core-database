-- The extract is extracted from Exerp on 2026-02-08
-- Audit of clip cards and subscription add-ons sold through API users
-- Online Shop Product Audit
-- Audits Clip Cards and Subscription Add-ons sold through online API users
-- Filters for Sitecore API User (100p2401) and Webapps API User (100p65017)

WITH api_users AS (
    SELECT 100 AS center_id, 2401 AS person_id, '100p2401' AS api_user_id, 'Sitecore API User' AS api_user_name
    UNION ALL
    SELECT 100 AS center_id, 65017 AS person_id, '100p65017' AS api_user_id, 'Webapps API User' AS api_user_name
),

-- Clip Card Sales by API Users
clipcard_sales AS (
    SELECT 
        c.shortname AS "Club Name",
        c.id AS "Club ID",
        prod.name AS "Product Name",
        'Clip Card' AS "Product Type",
        au.api_user_name AS "Sold By",
        invl.total_amount AS "Product Price",
        COUNT(*) AS "Number of Sales"
    FROM 
        clipcards cc
    JOIN
        persons p
        ON p.center = cc.owner_center
        AND p.id = cc.owner_id
    JOIN 
        products prod 
        ON prod.center = cc.center
        AND prod.id = cc.ID 
    JOIN                                                 
        invoices inv
        ON inv.center = cc.invoiceline_center
        AND inv.id = cc.invoiceline_id								
    JOIN
        invoice_lines_mt invl
        ON cc.invoiceline_center = invl.center
        AND cc.invoiceline_id = invl.id
        AND cc.invoiceline_subid = invl.subid
    JOIN
        centers c
        ON c.id = p.center
    JOIN
        api_users au
        ON au.center_id = inv.employee_center
        AND au.person_id = (
            SELECT emp.personid 
            FROM employees emp 
            WHERE emp.center = inv.employee_center 
            AND emp.id = inv.employee_id
        )
    WHERE 
        cc.cancelled IS FALSE
        AND cc.blocked IS FALSE
        AND inv.trans_time BETWEEN datetolongC(TO_CHAR(CAST(:From AS DATE), 'YYYY-MM-dd HH24:MI'), p.center) 
                                AND datetolongC(TO_CHAR((CAST(:To AS DATE) + INTERVAL '1 day'), 'YYYY-MM-dd HH24:MI'), p.center) - 1
        AND p.center IN (:Scope)
    GROUP BY
        c.shortname,
        c.id,
        prod.name,
        au.api_user_name,
        invl.total_amount
),

-- Subscription Add-ons by API Users
addon_sales AS (
    SELECT 
        c.shortname AS "Club Name",
        c.id AS "Club ID",
        prod.name AS "Product Name",
        'Subscription Add-on' AS "Product Type",
        au.api_user_name AS "Sold By",
        sao.individual_price_per_unit AS "Product Price",
        COUNT(*) AS "Number of Sales"
    FROM
        subscription_addon sao
    JOIN       
        subscriptions s
        ON sao.subscription_center = s.center 
        AND sao.subscription_id = s.id
        AND s.state != 5 
        AND s.sub_state != 8
    JOIN
        persons p
        ON p.center = s.owner_center
        AND p.id = s.owner_id
    JOIN  
        masterproductregister mpr_addon 
        ON mpr_addon.id = sao.addon_product_id
    JOIN 
        products prod
        ON prod.center = sao.center_id
        AND prod.globalid = mpr_addon.globalid       
    JOIN
        centers c
        ON c.id = p.center 
    JOIN
        employees emp
        ON emp.center = sao.employee_creator_center
        AND emp.id = sao.employee_creator_id
    JOIN
        api_users au
        ON au.center_id = emp.center
        AND au.person_id = emp.personid
    WHERE 
        sao.cancelled = 'false'
        AND sao.creation_time BETWEEN datetolongC(TO_CHAR(CAST(:From AS DATE), 'YYYY-MM-dd HH24:MI'), p.center) 
                                   AND datetolongC(TO_CHAR((CAST(:To AS DATE) + INTERVAL '1 day'), 'YYYY-MM-dd HH24:MI'), p.center) - 1
        AND p.center IN (:Scope)
    GROUP BY
        c.shortname,
        c.id,
        prod.name,
        au.api_user_name,
        sao.individual_price_per_unit
),

-- Combined results with club count
combined_results AS (
    SELECT * FROM clipcard_sales
    UNION ALL
    SELECT * FROM addon_sales
),

-- Add club count for each product
product_club_counts AS (
    SELECT 
        "Product Name",
        "Product Type",
        COUNT(DISTINCT "Club ID") AS "Number of Clubs with Product"
    FROM combined_results
    GROUP BY "Product Name", "Product Type"
)

-- Final output with all requested fields
SELECT 
    cr."Club Name",
    cr."Club ID", 
    cr."Product Name",
    cr."Product Type",
    cr."Sold By",
    cr."Product Price",
    cr."Number of Sales",
    pcc."Number of Clubs with Product"
FROM 
    combined_results cr
LEFT JOIN 
    product_club_counts pcc
    ON cr."Product Name" = pcc."Product Name"
    AND cr."Product Type" = pcc."Product Type"
ORDER BY 
    cr."Product Type",
    cr."Product Name",
    cr."Club Name";