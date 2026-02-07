-- Member Length of Stay Report
-- Includes total length of stay for members and staff members

WITH
    params AS
    (
        SELECT
            c.id AS CENTER_ID
        FROM
            centers c
    ),
    subscription_count AS
    (
        SELECT
            s.owner_center,
            s.owner_id,
            COUNT(*) as total_subscriptions,
            MIN(s.start_date) as first_subscription_start,
            MAX(s.end_date) as last_subscription_end
        FROM
            subscriptions s
        WHERE
            s.state NOT IN (5, 7, 8) -- Exclude deleted, window, and created states
        GROUP BY
            s.owner_center, s.owner_id
    )

SELECT
    p.center || 'p' || p.id AS "Exerp ID",
    p.firstname AS "First Name",
    p.lastname AS "Last Name",
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
    p.first_active_start_date AS "Initial Start Date",
    p.last_active_start_date AS "Last Active Start Date", 
    p.last_active_end_date AS "Last Active End Date",
    
    -- Length of Stay Calculations
    COALESCE(p.first_active_start_date, sc.first_subscription_start) AS "Membership Start Date",
    CASE 
        WHEN p.status IN (1, 3) THEN CURRENT_DATE -- Active or Temp Inactive
        ELSE COALESCE(p.last_active_end_date, sc.last_subscription_end, CURRENT_DATE)
    END AS "Membership End Date (Calculated)",
    
    -- Total days as member
    CASE 
        WHEN p.status IN (1, 3) THEN 
            CURRENT_DATE - COALESCE(p.first_active_start_date, sc.first_subscription_start)
        ELSE 
            COALESCE(p.last_active_end_date, sc.last_subscription_end, CURRENT_DATE) - 
            COALESCE(p.first_active_start_date, sc.first_subscription_start)
    END AS "Total Length of Stay (Days)",
    
    -- Convert to years and months for readability
    CASE 
        WHEN p.status IN (1, 3) THEN 
            ROUND((CURRENT_DATE - COALESCE(p.first_active_start_date, sc.first_subscription_start)) / 365.25, 2)
        ELSE 
            ROUND((COALESCE(p.last_active_end_date, sc.last_subscription_end, CURRENT_DATE) - 
            COALESCE(p.first_active_start_date, sc.first_subscription_start)) / 365.25, 2)
    END AS "Total Length of Stay (Years)",
    
    -- Member Days calculated from dates (simplified approach)
    CASE 
        WHEN p.status IN (1, 3) AND p.last_active_start_date IS NOT NULL THEN 
            CURRENT_DATE - p.last_active_start_date
        WHEN p.last_active_start_date IS NOT NULL AND p.last_active_end_date IS NOT NULL THEN
            p.last_active_end_date - p.last_active_start_date
        ELSE 0
    END AS "Current Period Member Days",
    
    -- Subscription information
    COALESCE(sc.total_subscriptions, 0) AS "Number of Subscriptions",
    sc.first_subscription_start AS "First Subscription Start",
    
    -- Additional member information
    peeaMobile.txtvalue AS "Mobile Number",
    peeaEmail.txtvalue AS "Email Address",
    c.shortname AS "Center"

FROM 
    persons p
JOIN
    centers c
    ON c.id = p.center
JOIN
    params
    ON params.CENTER_ID = p.center
LEFT JOIN
    subscription_count sc
    ON sc.owner_center = p.center
    AND sc.owner_id = p.id
LEFT JOIN
    person_ext_attrs peeaMobile
    ON peeaMobile.personcenter = p.center
    AND peeaMobile.personid = p.id
    AND peeaMobile.name = '_eClub_PhoneSMS'
LEFT JOIN
    person_ext_attrs peeaEmail
    ON peeaEmail.personcenter = p.center
    AND peeaEmail.personid = p.id
    AND peeaEmail.name = '_eClub_Email'

WHERE
    p.center IN (:Scope)
    AND p.status IN (1, 2, 3) -- Only Active (1), Inactive (2), Temporary Inactive (3)
    AND p.persontype IN (0, 1, 2, 3, 4, 5, 7, 9, 10) -- Exclude Family (6) but include Staff (2, 10)
    AND sc.total_subscriptions > 0 -- Must have had at least one subscription

ORDER BY 
    c.shortname,
    "Total Length of Stay (Days)" DESC,
    p.lastname, 
    p.firstname;