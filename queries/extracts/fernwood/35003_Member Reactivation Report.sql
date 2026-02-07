-- Alternative approach: Track members who rejoined by analyzing subscription state transitions
-- This looks for members who have had ended subscriptions followed by new active ones

WITH 
    params AS (
        SELECT
            c.id AS CENTER_ID
        FROM
            centers c
    ),
    active_member_subscriptions AS (
        -- Get all subscriptions that count towards Active Member Count
        SELECT 
            s.owner_center,
            s.owner_id,
            s.center AS subscription_center,
            s.id AS subscription_id,
            s.start_date,
            s.end_date,
            s.state,
            s.sub_state,
            prod.name AS subscription_name,
            -- Create timeline ordering
            ROW_NUMBER() OVER (
                PARTITION BY s.owner_center, s.owner_id 
                ORDER BY s.start_date, s.id
            ) AS subscription_sequence
        FROM 
            subscriptions s
        JOIN 
            products prod ON prod.center = s.subscriptiontype_center 
            AND prod.id = s.subscriptiontype_id
        WHERE 
            s.owner_center IN (:Scope)
            -- Only include products that count towards Active Member Count
            AND prod.center || 'prod' || prod.id NOT IN 
                (SELECT pg.product_center || 'prod' || pg.product_id AS ID 
                 FROM product_and_product_group_link pg 
                 WHERE pg.product_group_id = 402)
    ),
    subscription_transitions AS (
        -- Identify subscription patterns indicating rejoining
        SELECT 
            curr.owner_center,
            curr.owner_id,
            curr.subscription_center || 'ss' || curr.subscription_id AS "Current Subscription ID",
            curr.subscription_name AS "Current Subscription Name",
            curr.start_date AS "Current Start Date",
            curr.end_date AS "Current End Date",
            curr.state AS current_state,
            CASE 
                WHEN curr.state = 2 THEN 'ACTIVE'
                WHEN curr.state = 3 THEN 'ENDED' 
                WHEN curr.state = 4 THEN 'FROZEN'
                ELSE curr.state::TEXT
            END AS "Current State",
            -- Previous subscription details
            prev.subscription_center || 'ss' || prev.subscription_id AS "Previous Subscription ID",
            prev.subscription_name AS "Previous Subscription Name",
            prev.end_date AS "Previous End Date",
            prev.state AS previous_state,
            CASE 
                WHEN prev.state = 2 THEN 'ACTIVE'
                WHEN prev.state = 3 THEN 'ENDED'
                WHEN prev.state = 4 THEN 'FROZEN' 
                ELSE prev.state::TEXT
            END AS "Previous State",
            -- Calculate gap between subscriptions
            (curr.start_date - prev.end_date) AS "Gap Days",
            -- Identify rejoining pattern
            CASE 
                WHEN prev.state = 3 AND curr.state = 2
                     AND (curr.start_date - prev.end_date) > 0
                THEN 'Rejoined After Cancellation'
                WHEN prev.state = 3 AND curr.state = 2
                     AND (curr.start_date - prev.end_date) <= 0  
                THEN 'Immediate Restart'
                WHEN prev.state = 2 AND curr.state = 2
                     AND (curr.start_date - prev.end_date) > 30
                THEN 'Rejoined After Long Gap'
                ELSE 'Continuous/Upgrade'
            END AS "Transition Type"
        FROM 
            active_member_subscriptions curr
        LEFT JOIN 
            active_member_subscriptions prev
            ON curr.owner_center = prev.owner_center
            AND curr.owner_id = prev.owner_id  
            AND curr.subscription_sequence = prev.subscription_sequence + 1
        WHERE 
            prev.subscription_id IS NOT NULL  -- Only members with multiple subscriptions
    ),
    member_details AS (
        -- Get member personal information
        SELECT 
            p.center,
            p.id,
            p.center || 'p' || p.id AS "Person ID",
            p.external_id AS "External ID", 
            p.firstname AS "First Name",
            p.lastname AS "Last Name",
            CASE
                WHEN p.status = 1 THEN 'Active'
                WHEN p.status = 2 THEN 'Inactive'
                WHEN p.status = 3 THEN 'Temporary Inactive' 
                WHEN p.status = 4 THEN 'Transferred'
                ELSE 'Other'
            END AS "Current Person Status",
            p.first_active_start_date AS "First Active Start Date",
            p.last_active_start_date AS "Last Active Start Date",
            -- Using the same pattern as other working extracts
            peeaHome.txtvalue AS "Home Phone",
            peeaMobile.txtvalue AS "Mobile Number",
            peeaEmail.txtvalue AS "Email Address"
        FROM 
            persons p
        LEFT JOIN
            person_ext_attrs peeaEmail
            ON peeaEmail.personcenter = p.center
            AND peeaEmail.personid = p.id
            AND peeaEmail.name = '_eClub_Email'
        LEFT JOIN
            person_ext_attrs peeaMobile
            ON peeaMobile.personcenter = p.center
            AND peeaMobile.personid = p.id
            AND peeaMobile.name = '_eClub_PhoneSMS' 
        LEFT JOIN
            person_ext_attrs peeaHome
            ON peeaHome.personcenter = p.center
            AND peeaHome.personid = p.id
            AND peeaHome.name = '_eClub_PhoneHome'
        WHERE 
            p.center IN (:Scope)
    ),
    rejoined_summary AS (
        -- Summarize rejoining patterns per member
        SELECT 
            owner_center,
            owner_id,
            COUNT(*) AS "Total Transitions",
            COUNT(CASE WHEN "Transition Type" = 'Rejoined After Cancellation' THEN 1 END) AS "Rejoined Count",
            COUNT(CASE WHEN "Transition Type" = 'Rejoined After Long Gap' THEN 1 END) AS "Long Gap Count",
            MAX(CASE WHEN "Transition Type" IN ('Rejoined After Cancellation', 'Rejoined After Long Gap') 
                     THEN "Current Start Date" END) AS "Most Recent Rejoin Date",
            MAX("Gap Days") AS "Longest Gap Days",
            STRING_AGG(DISTINCT "Transition Type", ', ') AS "Transition Types"
        FROM 
            subscription_transitions
        GROUP BY 
            owner_center, owner_id
        HAVING 
            COUNT(CASE WHEN "Transition Type" IN ('Rejoined After Cancellation', 'Rejoined After Long Gap') THEN 1 END) > 0
    )

SELECT 
    md."Person ID",
    md."External ID",
    md."First Name", 
    md."Last Name",
    md."Current Person Status",
    md."First Active Start Date",
    md."Last Active Start Date", 
    rs."Most Recent Rejoin Date",
    rs."Rejoined Count",
    rs."Long Gap Count", 
    rs."Total Transitions",
    rs."Longest Gap Days",
    rs."Transition Types",
    md."Home Phone",
    md."Mobile Number", 
    md."Email Address",
    -- Categorize rejoining behavior
    CASE 
        WHEN rs."Rejoined Count" >= 3 THEN 'Frequent Rejoiner (3+)'
        WHEN rs."Rejoined Count" = 2 THEN 'Multiple Rejoiner (2)'
        WHEN rs."Rejoined Count" = 1 AND rs."Longest Gap Days" > 90 THEN 'Long-term Returner'
        WHEN rs."Rejoined Count" = 1 AND rs."Longest Gap Days" > 30 THEN 'Medium-term Returner'
        ELSE 'Recent Rejoiner'
    END AS "Rejoiner Category"
FROM 
    member_details md
JOIN 
    rejoined_summary rs
    ON md.center = rs.owner_center 
    AND md.id = rs.owner_id
WHERE 
    -- Filter by recent rejoin date
    rs."Most Recent Rejoin Date" BETWEEN :From AND :To
ORDER BY 
    rs."Most Recent Rejoin Date" DESC,
    rs."Rejoined Count" DESC,
    rs."Longest Gap Days" DESC;