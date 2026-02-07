SELECT DISTINCT
    p.center || 'p' || p.id AS "Person ID",
    p.external_id AS "External ID",
    p.center AS "Center ID",
    c.shortname AS "Centre",
    p.firstname AS "First Name",
    p.lastname AS "Last Name",
    CASE
        WHEN p.status = 1 THEN 'Active'
        WHEN p.status = 3 THEN 'Temporary Inactive'
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
    peeaMobile.txtvalue AS "Mobile Number",
    peeaEmail.txtvalue AS "Email Address",
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
    END AS "Subscription State"
FROM 
    persons p
JOIN
    subscriptions s
    ON s.owner_center = p.center
    AND s.owner_id = p.id
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
JOIN
    centers c
    ON c.id = p.center
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
WHERE
    pg.name = 'Active Member Count'
    AND p.status IN (1, 3)  -- Active (1) and Temporary Inactive (3)
    AND s.state IN (2, 4)   -- Active (2) and Frozen (4) subscriptions
    AND p.center IN (:Scope)
ORDER BY 
    "Center ID", p.lastname, p.firstname;