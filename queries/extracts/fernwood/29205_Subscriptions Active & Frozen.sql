WITH
    params AS MATERIALIZED
    (
        SELECT
            c.id AS CENTER_ID,
            datetolongtz(TO_CHAR(CAST(CURRENT_DATE-8 AS DATE), 'YYYY-MM-dd'), c.time_zone) AS FROM_DATE,
            datetolongtz(TO_CHAR(CAST(CURRENT_DATE AS DATE), 'YYYY-MM-dd'), c.time_zone) AS TO_DATE
        FROM
            centers c
    ),
    last_visit AS
    (
    SELECT
        p.center AS person_center,
        p.id AS person_id,
        MAX(ck.checkin_time) AS last_visit_date
    FROM
        persons p
    JOIN
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
    JOIN
        params
    ON ck.checkin_center = params.CENTER_ID
    WHERE
        ck.checkin_time BETWEEN params.FROM_DATE AND params.TO_DATE
    GROUP BY
        ck.person_center, ck.person_id
    )  
SELECT
    p.center || 'p' || p.id AS "Person ID",  -- Person ID
    p.external_id AS "External ID",  -- External ID
    s.center || 'ss' || s.id AS "Subscription ID",  -- Subscription ID
    c.shortname AS "Centre",  -- Centre
    CASE
        WHEN p.status = 1 THEN 'Active' 
        WHEN p.status = 3 THEN 'Temporary Inactive'
        ELSE ''
    END AS "Person Status",  -- Person Status
    CASE
        WHEN p.persontype = 0 THEN 'Private'
        WHEN p.persontype = 1 THEN 'Student'
        WHEN p.persontype = 2 THEN 'Staff'  -- Staff included
        WHEN p.persontype = 3 THEN 'Friend'
        WHEN p.persontype = 4 THEN 'Corporate'
        WHEN p.persontype = 5 THEN 'One Man Corporate'
        WHEN p.persontype = 6 THEN 'Family'
        WHEN p.persontype = 7 THEN 'Senior'
        WHEN p.persontype = 8 THEN 'Guest'
        WHEN p.persontype = 9 THEN 'Child'
        WHEN p.persontype = 10 THEN 'External Staff' 
        ELSE 'Unknown'
    END AS "Person Type",  -- Person Type
    p.firstname AS "First Name",  -- First Name
    p.lastname AS "Last Name",  -- Last Name
    prod.NAME AS "Subscription Name",  -- Subscription Name
    s.start_date AS "Subscription Start Date",  -- Subscription Start Date
    s.end_date AS "Subscription End Date",  -- Subscription End Date
    s.binding_end_date AS "Binding End Date",  -- Binding End Date
    TO_CHAR(TO_TIMESTAMP(last_visit.last_visit_date / 1000) + INTERVAL '10 hours', 'DD-MM-YYYY') AS "Last Visit Date",  -- Last Visit Date with time adjustment and formatted as DD-MM-YYYY
    COALESCE(visits_last_7_days.visits_7_days, 0) AS "Visits in Last 7 Days",  -- Visits in Last 7 Days
    COALESCE(CURRENT_DATE - (TO_TIMESTAMP(last_visit.last_visit_date / 1000) + INTERVAL '10 hours')::date, 0) AS "Days Since Last Visit",  -- Days Since Last Visit
    COUNT(ck.id) AS "Total Number of Visits",  -- Total Number of Visits
    p.first_active_start_date AS "First Active Start Date",  -- First Active Start Date moved to the end
    p.last_active_start_date AS "Last Active Start Date"  -- Last Active Start Date moved to the end
FROM 
    persons p 
JOIN
    subscriptions s
    ON p.center = s.owner_center
    AND p.id = s.owner_id
JOIN
    subscriptiontypes st
    ON st.center = s.subscriptiontype_center
    AND st.id = s.subscriptiontype_id
JOIN
    products prod
    ON prod.center = st.center
    AND prod.id = st.id
LEFT JOIN
    checkins ck
    ON p.center = ck.person_center
    AND p.id = ck.person_id
JOIN
    centers c
    ON c.id = p.center
LEFT JOIN
    last_visit
    ON p.center = last_visit.person_center
    AND p.id = last_visit.person_id
LEFT JOIN
    visits_last_7_days
    ON p.center = visits_last_7_days.person_center
    AND p.id = visits_last_7_days.person_id
WHERE
    s.state NOT IN (3, 7, 8)  -- Exclude subscriptions with states 'ended' (3), 'window' (7), and 'created' (8)
    AND s.sub_state NOT IN (4, 6, 8)  -- Exclude subscriptions with sub-states 'downgraded' (4), 'transferred' (6), and 'cancelled' (8)
    AND p.center IN (:Scope)
GROUP BY
    p.center,
    p.id,
    p.external_id,
    c.shortname,
    p.firstname,
    p.lastname,
    prod.NAME,
    s.start_date,
    s.end_date,
    s.binding_end_date,
    s.center,
    s.id,
    last_visit.last_visit_date,
    visits_last_7_days.visits_7_days,
    p.first_active_start_date,
    p.last_active_start_date
ORDER BY 
    p.center, p.lastname, p.firstname;
