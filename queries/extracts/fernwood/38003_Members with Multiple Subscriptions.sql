-- The extract is extracted from Exerp on 2026-02-08
-- Identifies ACTIVEand TEMP INACTIVE members (excluding staff) who have 2 or more active or frozen subscriptions. Excludes Personal Training Sessions and Sauna Sessions. Filterable by scope/center.
WITH active_members AS (
    SELECT 
        p.center,
        p.id,
        p.center || 'p' || p.id AS "Person ID",
        p.external_id AS "External ID",
        p.firstname AS "First Name",
        p.lastname AS "Last Name",
        CASE
            WHEN p.status = 1 THEN 'Active'
            WHEN p.status = 3 THEN 'Temporary Inactive'
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
        COUNT(DISTINCT s.id) AS "Active Subscription Count"
    FROM 
        persons p
    JOIN 
        subscriptions s
        ON s.owner_center = p.center
        AND s.owner_id = p.id
    JOIN 
        products prod
        ON prod.center = s.subscriptiontype_center
        AND prod.id = s.subscriptiontype_id
    WHERE 
        p.status IN (1, 3)  -- Active (1) and Temporary Inactive (3)
        AND s.state IN (2, 4)  -- ACTIVE (2) and FROZEN (4)
        AND p.center IN (:Scope)
        AND p.persontype != 2  -- Exclude Staff
        AND prod.name NOT IN ('Personal Training Sessions', 'Sauna Sessions')  -- Exclude PT and Sauna Sessions
    GROUP BY 
        p.center,
        p.id,
        p.external_id,
        p.firstname,
        p.lastname,
        p.status,
        p.persontype
    HAVING 
        COUNT(DISTINCT s.id) >= 2  -- Two or more active subscriptions
)
SELECT 
    am.center,
    am.id,
    am."Person ID",
    am."External ID",
    am."First Name",
    am."Last Name",
    am."Person Status",
    am."Person Type",
    am."Active Subscription Count",
    c.shortname AS "Centre",
    peeaMobile.txtvalue AS "Mobile Number",
    peeaEmail.txtvalue AS "Email Address",
    STRING_AGG(prod.name, '; ' ORDER BY s.start_date) AS "Subscription Names",
    STRING_AGG(
        CASE 
            WHEN s.state = 2 THEN 'ACTIVE'
            WHEN s.state = 4 THEN 'FROZEN'
        END, 
        '; ' 
        ORDER BY s.start_date
    ) AS "Subscription States"
FROM 
    active_members am
JOIN 
    persons p
    ON p.center = am.center
    AND p.id = am.id
JOIN 
    subscriptions s
    ON s.owner_center = p.center
    AND s.owner_id = p.id
    AND s.state IN (2, 4)
JOIN 
    centers c
    ON c.id = p.center
JOIN 
    products prod
    ON prod.center = s.subscriptiontype_center
    AND prod.id = s.subscriptiontype_id
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
    prod.name NOT IN ('Personal Training Sessions', 'Sauna Sessions')  -- Also exclude from final results
GROUP BY 
    am.center,
    am.id,
    am."Person ID",
    am."External ID",
    am."First Name",
    am."Last Name",
    am."Person Status",
    am."Person Type",
    am."Active Subscription Count",
    c.shortname,
    peeaMobile.txtvalue,
    peeaEmail.txtvalue
ORDER BY 
    am."Active Subscription Count" DESC,
    am."Last Name",
    am."First Name";
    