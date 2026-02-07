WITH
    params AS MATERIALIZED (
        SELECT
            c.id AS CENTER_ID
        FROM
            centers c
    )
SELECT
    p.center || 'p' || p.id AS "Person ID",
    p.external_id AS "External ID",
    c.shortname AS "Centre",
    CASE
        WHEN p.status = 1 THEN 'Active' 
        WHEN p.status = 2 THEN 'Inactive' 
        WHEN p.status = 3 THEN 'Temporary Inactive'
        WHEN p.status = 4 THEN 'Transferred'  
        ELSE ''
    END AS "Person Status",
    CASE
        WHEN p.persontype = 0 THEN 'Private'
        WHEN p.persontype = 1 THEN 'Student'
        WHEN p.persontype = 2 THEN 'Staff'
        WHEN p.persontype = 3 THEN 'Friend'
        WHEN p.persontype = 4 THEN 'Corporate'
        WHEN p.persontype = 5 THEN 'One Man Corporate'
        WHEN p.persontype = 6 THEN 'Family'
        WHEN p.persontype = 7 THEN 'Senior'
        WHEN p.persontype = 8 THEN 'Guest'
        WHEN p.persontype = 9 THEN 'Child'
        WHEN p.persontype = 10 THEN 'External Staff' 
        ELSE 'Unknown'
    END AS "Person Type",
    p.firstname AS "First Name",
    p.lastname AS "Last Name",
    c.id || 'ss' || s.id AS "Subscription ID",
    prod.name AS "Subscription Name",
    s.start_date AS "Subscription Start Date",
    s.end_date AS "Subscription End Date",
    CASE
        WHEN s.state = 2 THEN 'ACTIVE'
        WHEN s.state = 3 THEN 'ENDED'
        WHEN s.state = 4 THEN 'FROZEN'
        WHEN s.state = 7 THEN 'WINDOW'
        WHEN s.state = 8 THEN 'CREATED'
        ELSE s.state::TEXT
    END AS "Subscription State",
    CASE
        WHEN s.sub_state = 1 THEN 'NONE'
        WHEN s.sub_state = 3 THEN 'UPGRADED'
        WHEN s.sub_state = 4 THEN 'DOWNGRADED'
        WHEN s.sub_state = 5 THEN 'EXTENDED'
        WHEN s.sub_state = 6 THEN 'TRANSFERRED'
        WHEN s.sub_state = 8 THEN 'CANCELLED'
        WHEN s.sub_state = 9 THEN 'BLOCKED'
        WHEN s.sub_state = 10 THEN 'CHANGED'
        ELSE s.sub_state::TEXT
    END AS "Subscription Sub State",
    s.binding_end_date AS "Binding End Date",
    sp.price AS "Subscription Price",

    -- Pro-Rata PIF Remaining Calculation
    CASE 
        WHEN sp.price IS NULL OR s.start_date IS NULL OR s.end_date IS NULL THEN NULL
        WHEN CURRENT_DATE >= s.end_date THEN 0
        ELSE ROUND(
            (sp.price / NULLIF(s.end_date - s.start_date, 0)) * GREATEST(s.end_date - CURRENT_DATE, 0),
            2
        )
    END AS "Pro-Rata PIF Remaining"

FROM 
    persons p 
JOIN
    subscriptions s
    ON s.owner_center = p.center
    AND s.owner_id = p.id        
JOIN
    centers c
    ON c.id = p.center
JOIN
    products prod
    ON prod.center = s.subscriptiontype_center
    AND prod.id = s.subscriptiontype_id
LEFT JOIN
    subscription_price sp
    ON sp.subscription_center = s.center
    AND sp.subscription_id = s.id
WHERE
    p.center IN (:Scope)
    AND p.status IN (1, 3)
    AND s.state NOT IN (3, 7, 8)
AND (
    LOWER(prod.name) LIKE '%pif%' OR
    LOWER(prod.name) LIKE '%paid in full%'
)
GROUP BY
    p.center,
    p.id,
    p.external_id,
    c.shortname,
    p.firstname,
    p.lastname,
    c.id,
    s.id,
    prod.name,
    s.start_date,
    s.end_date,
    s.state,
    s.sub_state,
    s.binding_end_date,
    sp.price
ORDER BY 
    p.center, p.lastname, p.firstname;
