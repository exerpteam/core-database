-- Active Member Count Product Sales Report
-- This report shows subscription sales of products in the "Active Member Count" product group
-- FIXED: Uses specific product group ID instead of fuzzy name matching
-- Parameters: :Scope (center selection), :From (date), :To (date)

WITH
    params AS
    (
        SELECT
            /*+ materialize */
            datetolongC(TO_CHAR(CAST(:From AS DATE), 'YYYY-MM-dd HH24:MI'), c.id) AS FromDate,
            c.id AS CENTER_ID,
            CAST((datetolongC(TO_CHAR((CAST(:To AS DATE) + INTERVAL '1 day'), 'YYYY-MM-dd HH24:MI'), c.id) - 1) AS BIGINT) AS ToDate
        FROM
            centers c
    )
SELECT 
    c.shortname AS "Center Name",
    p.firstname AS "First Name",
    p.lastname AS "Last Name", 
    p.center || 'p' || p.id AS "Person ID",
    p.external_id AS "External ID",
    peeaEmail.txtvalue AS "Email Address",
    prod.name AS "Product Name",
    pg.name AS "Product Group Name",  -- Added for verification
    longtodatec(s.creation_time, p.center) AS "Sale Date",
    COALESCE(ss.price_period, sp.price) AS "Sale Amount",
    CASE
        WHEN s.state = 2 THEN 'ACTIVE'
        WHEN s.state = 3 THEN 'ENDED'
        WHEN s.state = 4 THEN 'FROZEN'
        WHEN s.state = 7 THEN 'WINDOW'
        WHEN s.state = 8 THEN 'CREATED'
        ELSE 'UNKNOWN'
    END AS "Subscription Status",
    CASE
        WHEN p.status = 0 THEN 'Lead'
        WHEN p.status = 1 THEN 'Active'
        WHEN p.status = 2 THEN 'Inactive'
        WHEN p.status = 3 THEN 'Temporary Inactive'
        WHEN p.status = 4 THEN 'Transferred'
        WHEN p.status = 5 THEN 'Duplicate'
        WHEN p.status = 6 THEN 'Prospect'
        WHEN p.status = 7 THEN 'Deleted'
        WHEN p.status = 8 THEN 'Anonymized'
        WHEN p.status = 9 THEN 'Contact'
        ELSE 'Unknown'
    END AS "Person Status",
    s.center || 'ss' || s.id AS "Subscription ID"  -- Added for reference
FROM
    subscriptions s        
JOIN
    subscriptiontypes st
    ON st.center = s.subscriptiontype_center
    AND st.id = s.subscriptiontype_id
JOIN
    products prod
    ON prod.center = st.center
    AND prod.id = st.id
JOIN
    product_and_product_group_link pgl
    ON pgl.product_center = prod.center  
    AND pgl.product_id = prod.id
JOIN
    product_group pg
    ON pg.id = pgl.product_group_id
    -- FIXED: Use specific product group ID instead of fuzzy matching
    AND pg.id = 5601  -- Active Member Count product group
JOIN
    persons p
    ON p.center = s.owner_center
    AND p.id = s.owner_id
JOIN
    centers c
    ON c.id = p.center
LEFT JOIN
    subscription_sales ss
    ON s.center = ss.subscription_center
    AND s.id = ss.subscription_id
LEFT JOIN
    subscription_price sp
    ON sp.subscription_center = s.center
    AND sp.subscription_id = s.id
    AND s.start_date > sp.from_date
    AND (s.start_date < sp.to_date OR sp.to_date IS NULL)
LEFT JOIN
    person_ext_attrs peeaEmail
    ON peeaEmail.personcenter = p.center
    AND peeaEmail.personid = p.id
    AND peeaEmail.name = '_eClub_Email'
JOIN 
    params 
    ON params.CENTER_ID = s.center  
WHERE 
    s.creation_time BETWEEN params.FromDate AND params.ToDate 
    AND s.center IN (:Scope)
    -- Optional: Exclude trial products by name if they're incorrectly in group 5601
    AND LOWER(prod.name) NOT LIKE '%trial%'
    AND LOWER(prod.name) NOT LIKE '%7 day%'
    AND LOWER(prod.name) NOT LIKE '%14 day%'
ORDER BY 
    c.shortname,
    s.creation_time DESC,
    p.lastname,
    p.firstname;