-- The extract is extracted from Exerp on 2026-02-08
--  
-- Fire & Ice Members Report (Recovery Product Group)
-- Shows all active and temporarily inactive members with Fire & Ice subscriptions

WITH 
    last_visit AS
    (
        SELECT
            p.center AS person_center,
            p.id AS person_id,
            MAX(ck.checkin_time) AS last_visit_date
        FROM
            persons p
        LEFT JOIN
            checkins ck
            ON p.center = ck.person_center
            AND p.id = ck.person_id
        GROUP BY
            p.center, p.id
    ),
    visits_last_7_days AS
    (
        SELECT
            ck.person_center,
            ck.person_id,
            COUNT(*) AS visits_7_days
        FROM
            checkins ck
        WHERE
            ck.checkin_time >= FLOOR(extract(epoch from (now() - INTERVAL '7 days'))*1000)
        GROUP BY
            ck.person_center, ck.person_id
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
        ELSE 'Other'
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
    p.address1 AS "Address",
    p.city AS "Suburb",
    p.zipcode AS "Post Code",
    p.birthdate AS "Birth Date",
    peeaHome.txtvalue AS "Home Phone",
    peeaMobile.txtvalue AS "Mobile Number",
    peeaEmail.txtvalue AS "Email Address",
    prod.name AS "Subscription Name",
    s.center || 'ss' || s.id AS "Subscription ID",
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
    sp.price AS "Subscription Price",
    s.binding_end_date AS "Binding End Date",
    p.first_active_start_date AS "First Active Start Date",
    p.last_active_start_date AS "Last Active Start Date",
    p.last_active_end_date AS "Last Active End Date",
    TO_CHAR(TO_TIMESTAMP(last_visit.last_visit_date / 1000) + INTERVAL '10 hours', 'DD-MM-YYYY') AS "Last Visit Date",
    COALESCE(CURRENT_DATE - (TO_TIMESTAMP(last_visit.last_visit_date / 1000) + INTERVAL '10 hours')::date, 0) AS "Days Since Last Visit",
    COALESCE(visits_last_7_days.visits_7_days, 0) AS "Visits in Last 7 Days",
    COUNT(ck.id) AS "Total Number of Visits"
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
    AND sp.cancelled IS FALSE
LEFT JOIN
    checkins ck
    ON p.center = ck.person_center
    AND p.id = ck.person_id
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
LEFT JOIN
    last_visit
    ON p.center = last_visit.person_center
    AND p.id = last_visit.person_id
LEFT JOIN
    visits_last_7_days
    ON p.center = visits_last_7_days.person_center
    AND p.id = visits_last_7_days.person_id
WHERE
    p.center IN (:Scope)
    AND p.status IN (1, 3)  -- Active (1) and Temporary Inactive (3)
    AND (
        -- Fire & Ice product names (adjust these based on actual product names)
        LOWER(prod.name) LIKE '%fire%ice%' 
        OR LOWER(prod.name) LIKE '%fire & ice%'
        OR LOWER(prod.name) LIKE '%fire and ice%'
        OR LOWER(prod.name) LIKE '%recovery%'
        -- Add specific Fire & Ice product names here if known
        -- OR prod.name IN ('Fire & Ice - 2 Sessions', 'Fire & Ice - 4 Sessions', etc.)
    )
    AND s.state NOT IN (3, 7, 8)  -- Exclude ended, window, and created subscriptions
GROUP BY
    p.center,
    p.id,
    p.external_id,
    c.shortname,
    p.firstname,
    p.lastname,
    p.address1,
    p.city,
    p.zipcode,
    p.birthdate,
    peeaHome.txtvalue,
    peeaMobile.txtvalue,
    peeaEmail.txtvalue,
    prod.name,
    s.center,
    s.id,
    s.start_date,
    s.end_date,
    s.state,
    s.sub_state,
    sp.price,
    s.binding_end_date,
    p.first_active_start_date,
    p.last_active_start_date,
    p.last_active_end_date,
    last_visit.last_visit_date,
    visits_last_7_days.visits_7_days
ORDER BY 
    p.center, p.lastname, p.firstname;