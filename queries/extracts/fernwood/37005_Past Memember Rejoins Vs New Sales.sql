-- Analysis: What percentage of new sales (Active Member Count) are from past members rejoining?
-- Compares past member rejoins vs completely new member sales

WITH 
    params AS (
        SELECT
            c.id AS CENTER_ID
        FROM
            centers c
    ),
    active_member_count_sales AS (
        -- Get all new sales that count towards Active Member Count within timeframe
        SELECT 
            s.owner_center,
            s.owner_id,
            s.center AS subscription_center,
            s.id AS subscription_id,
            s.start_date,
            s.end_date,
            s.state,
            prod.name AS subscription_name,
            p.center || 'p' || p.id AS "Person ID",
            p.external_id AS "External ID",
            p.firstname AS "First Name",
            p.lastname AS "Last Name",
            p.first_active_start_date,
            p.last_active_start_date,
            -- Determine if this is a past member or new member
            CASE 
                WHEN p.first_active_start_date != p.last_active_start_date 
                THEN 'Past Member Rejoin'
                ELSE 'New Member Sale'
            END AS "Sale Type"
        FROM 
            subscriptions s
        JOIN 
            products prod ON prod.center = s.subscriptiontype_center 
            AND prod.id = s.subscriptiontype_id
        JOIN 
            persons p ON p.center = s.owner_center 
            AND p.id = s.owner_id
        WHERE 
            s.owner_center IN (:Scope)
            -- Only include products that count towards Active Member Count
            AND prod.center || 'prod' || prod.id NOT IN 
                (SELECT pg.product_center || 'prod' || pg.product_id AS ID 
                 FROM product_and_product_group_link pg 
                 WHERE pg.product_group_id = 402)
            -- Sales within our analysis timeframe
            AND s.start_date BETWEEN :From AND :To
            -- Only count new sales (not existing subscriptions)
            AND s.state IN (2, 4, 7, 8)  -- Active, Frozen, Window, Created
    ),
    detailed_past_member_analysis AS (
        -- For past members, get more details about their rejoining pattern
        SELECT 
            ams.*,
            -- Calculate gap since last membership
            CASE 
                WHEN ams."Sale Type" = 'Past Member Rejoin' 
                THEN (ams.start_date - p.last_active_end_date)
                ELSE NULL
            END AS "Gap Days Since Last Membership"
        FROM 
            active_member_count_sales ams
        LEFT JOIN 
            persons p ON ams.owner_center = p.center 
            AND ams.owner_id = p.id
    ),
    sales_summary AS (
        -- Calculate summary statistics
        SELECT 
            COUNT(*) AS "Total Sales",
            COUNT(CASE WHEN "Sale Type" = 'Past Member Rejoin' THEN 1 END) AS "Past Member Rejoins",
            COUNT(CASE WHEN "Sale Type" = 'New Member Sale' THEN 1 END) AS "New Member Sales",
            -- Calculate percentages
            ROUND(
                (COUNT(CASE WHEN "Sale Type" = 'Past Member Rejoin' THEN 1 END) * 100.0) / 
                NULLIF(COUNT(*), 0), 2
            ) AS "Past Member Rejoin Percentage",
            ROUND(
                (COUNT(CASE WHEN "Sale Type" = 'New Member Sale' THEN 1 END) * 100.0) / 
                NULLIF(COUNT(*), 0), 2
            ) AS "New Member Sale Percentage"
        FROM 
            detailed_past_member_analysis
    ),
    gap_analysis AS (
        -- Analyze gap patterns for past member rejoins
        SELECT 
            CASE 
                WHEN "Gap Days Since Last Membership" IS NULL THEN 'New Member'
                WHEN "Gap Days Since Last Membership" <= 30 THEN 'Short Gap (≤30 days)'
                WHEN "Gap Days Since Last Membership" <= 90 THEN 'Medium Gap (31-90 days)'
                WHEN "Gap Days Since Last Membership" <= 365 THEN 'Long Gap (3-12 months)'
                WHEN "Gap Days Since Last Membership" > 365 THEN 'Very Long Gap (>1 year)'
                ELSE 'Unknown Gap'
            END AS "Gap Category",
            COUNT(*) AS "Sales Count",
            ROUND(
                (COUNT(*) * 100.0) / 
                (SELECT COUNT(*) FROM detailed_past_member_analysis), 2
            ) AS "Percentage of Total Sales"
        FROM 
            detailed_past_member_analysis
        GROUP BY 
            CASE 
                WHEN "Gap Days Since Last Membership" IS NULL THEN 'New Member'
                WHEN "Gap Days Since Last Membership" <= 30 THEN 'Short Gap (≤30 days)'
                WHEN "Gap Days Since Last Membership" <= 90 THEN 'Medium Gap (31-90 days)'
                WHEN "Gap Days Since Last Membership" <= 365 THEN 'Long Gap (3-12 months)'
                WHEN "Gap Days Since Last Membership" > 365 THEN 'Very Long Gap (>1 year)'
                ELSE 'Unknown Gap'
            END
    )

-- Main output: Summary statistics
SELECT 
    'SUMMARY STATISTICS' AS "Report Section",
    CAST(NULL AS TEXT) AS "Gap Category",
    ss."Total Sales",
    ss."Past Member Rejoins" AS "Sales Count", 
    ss."Past Member Rejoin Percentage" AS "Percentage of Total Sales",
    CAST(NULL AS TEXT) AS "Detail"
FROM 
    sales_summary ss

UNION ALL

SELECT 
    'NEW MEMBER SALES' AS "Report Section",
    'New Members' AS "Gap Category", 
    ss."Total Sales",
    ss."New Member Sales" AS "Sales Count",
    ss."New Member Sale Percentage" AS "Percentage of Total Sales",
    'Completely new members' AS "Detail"
FROM 
    sales_summary ss

UNION ALL

SELECT 
    'PAST MEMBER BREAKDOWN' AS "Report Section",
    ga."Gap Category",
    (SELECT "Total Sales" FROM sales_summary) AS "Total Sales",
    ga."Sales Count",
    ga."Percentage of Total Sales",
    'Past members by gap length' AS "Detail"
FROM 
    gap_analysis ga
WHERE 
    ga."Gap Category" != 'New Member';	