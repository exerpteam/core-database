-- The extract is extracted from Exerp on 2026-02-08
-- Automated- sent by email daily - personal details have been removed.
WITH
    params AS MATERIALIZED (
        SELECT c.id AS CENTER_ID
        FROM centers c
    ),
    last_visit AS (
        SELECT
            ck.person_center,
            ck.person_id,
            MAX(TO_TIMESTAMP(ck.checkin_time / 1000) + INTERVAL '10 hours') AS last_visit_datetime
        FROM checkins ck
        GROUP BY ck.person_center, ck.person_id
    ),
    visits_last_7_days AS (
        SELECT
            ck.person_center,
            ck.person_id,
            COUNT(*) AS visits_7_days
        FROM checkins ck
        WHERE (TO_TIMESTAMP(ck.checkin_time / 1000) AT TIME ZONE 'Australia/Sydney')::date >= CURRENT_DATE - INTERVAL '7 days'
        GROUP BY ck.person_center, ck.person_id
    ),
    total_visits AS (
        SELECT
            ck.person_center,
            ck.person_id,
            COUNT(*) AS total_visits
        FROM checkins ck
        GROUP BY ck.person_center, ck.person_id
    ),
    latest_price AS (
        SELECT
            sp.subscription_center,
            sp.subscription_id,
            sp.price,
            ROW_NUMBER() OVER (
                PARTITION BY sp.subscription_center, sp.subscription_id
                ORDER BY sp.id DESC
            ) AS rn
        FROM subscription_price sp
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
    p.city AS "Suburb",
    TO_CHAR(p.first_active_start_date, 'DD/MM/YYYY') AS "First Active Start Date",
    TO_CHAR(p.last_active_start_date, 'DD/MM/YYYY') AS "Last Active Start Date",
    TO_CHAR(p.last_active_end_date, 'DD/MM/YYYY') AS "Last Active End Date",
    c.id || 'ss' || s.id AS "Subscription ID",
    prod.name AS "Subscription Name",
    TO_CHAR(s.start_date, 'DD/MM/YYYY') AS "Subscription Start Date",
    TO_CHAR(s.end_date, 'DD/MM/YYYY') AS "Subscription End Date",
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
    COALESCE(visits_last_7_days.visits_7_days, 0) AS "Visits in Last 7 Days",
    TO_CHAR(last_visit.last_visit_datetime, 'DD/MM/YYYY') AS "Last Visit Date",
    COALESCE(CURRENT_DATE - CAST(last_visit.last_visit_datetime AS DATE), 0) AS "Days Since Last Visit",
    COALESCE(total_visits.total_visits, 0) AS "Total Number of Visits",
    s.id AS "Subscription ID",
    TO_CHAR(s.binding_end_date, 'DD/MM/YYYY') AS "Binding End Date",
    latest_price.price AS "Subscription Price"
FROM persons p
JOIN subscriptions s
    ON s.owner_center = p.center
    AND s.owner_id = p.id
JOIN centers c
    ON c.id = p.center
JOIN products prod
    ON prod.center = s.subscriptiontype_center
    AND prod.id = s.subscriptiontype_id
LEFT JOIN latest_price
    ON latest_price.subscription_center = s.center
    AND latest_price.subscription_id = s.id
    AND latest_price.rn = 1
LEFT JOIN person_ext_attrs peeaEmail
    ON peeaEmail.personcenter = p.center
    AND peeaEmail.personid = p.id
    AND peeaEmail.name = '_eClub_Email'
LEFT JOIN person_ext_attrs peeaMobile
    ON peeaMobile.personcenter = p.center
    AND peeaMobile.personid = p.id
    AND peeaMobile.name = '_eClub_PhoneSMS'
LEFT JOIN person_ext_attrs peeaHome
    ON peeaHome.personcenter = p.center
    AND peeaHome.personid = p.id
    AND peeaHome.name = '_eClub_PhoneHome'
LEFT JOIN last_visit
    ON p.center = last_visit.person_center
    AND p.id = last_visit.person_id
LEFT JOIN visits_last_7_days
    ON p.center = visits_last_7_days.person_center
    AND p.id = visits_last_7_days.person_id
LEFT JOIN total_visits
    ON p.center = total_visits.person_center
    AND p.id = total_visits.person_id
WHERE
    p.center IN (:Scope)
    AND p.status IN (1, 3, 4)
    AND s.state NOT IN (3, 7)
    AND LOWER(prod.name) NOT ILIKE '%pt%'
    AND LOWER(prod.name) NOT ILIKE '%personal training%'
    AND LOWER(prod.name) NOT ILIKE '%hypoxi%'
    AND LOWER(prod.name) NOT ILIKE '%hdc%'
    AND LOWER(prod.name) NOT ILIKE '%Unlimited Childcare Access%'
    AND LOWER(prod.name) NOT ILIKE '%trial%'
    AND LOWER(prod.name) NOT ILIKE '%Complimentary Staff%'
	AND LOWER(prod.name) NOT ILIKE '%one month membership%'
    AND LOWER(prod.name) NOT ILIKE '%whf $30 for 30 days%'
    AND LOWER(prod.name) NOT ILIKE '%fiit30%'
    AND LOWER(prod.name) NOT ILIKE '%reformer flexi pif%'
    AND LOWER(prod.name) NOT ILIKE '%nutrition coaching%'
    AND LOWER(prod.name) NOT ILIKE '%childcare flexi pif%'
    AND LOWER(prod.name) NOT ILIKE '%squad goals referral%'
    AND LOWER(prod.name) NOT ILIKE '%day pass%'

GROUP BY
    p.center, p.id, p.external_id, c.shortname,
    p.firstname, p.lastname, p.first_active_start_date, p.last_active_start_date, p.last_active_end_date,
    p.city,
    c.id, s.id, prod.name, s.start_date, s.end_date, s.state, s.sub_state,
    s.binding_end_date, last_visit.last_visit_datetime, visits_last_7_days.visits_7_days,
    total_visits.total_visits, latest_price.price
ORDER BY p.center, p.lastname, p.firstname;
