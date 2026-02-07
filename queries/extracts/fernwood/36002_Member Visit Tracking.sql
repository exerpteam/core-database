-- Extract: Members with No Club Visits
-- Description: Identifies active members who have never visited the club or haven't visited within a specified time period
-- Parameters: :Scope (center selection), :Days_Since_Last_Visit (integer, optional - default to show all with no visits)

SELECT DISTINCT
    p.center ||'p'|| p.id AS "Person ID",
    p.external_id AS "External ID",
    c.shortname AS "Centre",
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
    prod.name AS "Current Subscription Name",
    CASE 
        WHEN s.state = 2 THEN 'ACTIVE'
        WHEN s.state = 3 THEN 'ENDED'
        WHEN s.state = 4 THEN 'FROZEN'
        WHEN s.state = 7 THEN 'WINDOW'
        WHEN s.state = 8 THEN 'CREATED'
        ELSE s.state::TEXT
    END AS "Subscription State",
    s.start_date AS "Subscription Start Date",
    s.end_date AS "Subscription End Date",
    p.first_active_start_date AS "First Active Start Date",
    p.last_active_start_date AS "Last Active Start Date",
    CASE 
        WHEN last_visit.last_visit_date IS NULL THEN 'Never Visited'
        ELSE TO_CHAR(TO_TIMESTAMP(last_visit.last_visit_date / 1000) + INTERVAL '10 hours', 'DD-MM-YYYY')
    END AS "Last Visit Date",
    CASE 
        WHEN last_visit.last_visit_date IS NULL THEN 999999
        ELSE COALESCE(CURRENT_DATE - (TO_TIMESTAMP(last_visit.last_visit_date / 1000) + INTERVAL '10 hours')::date, 999999)
    END AS "Days Since Last Visit",
    COALESCE(total_visits.visit_count, 0) AS "Total Number of Visits"
FROM 
    persons p
JOIN
    centers c ON c.id = p.center
LEFT JOIN
    subscriptions s ON s.owner_center = p.center 
                   AND s.owner_id = p.id
                   AND s.state IN (2, 4) -- Active or Frozen subscriptions only
LEFT JOIN
    products prod ON prod.center = s.subscriptiontype_center
                 AND prod.id = s.subscriptiontype_id
LEFT JOIN
    person_ext_attrs peeaEmail ON peeaEmail.personcenter = p.center
                              AND peeaEmail.personid = p.id
                              AND peeaEmail.name = '_eClub_Email'
LEFT JOIN
    person_ext_attrs peeaMobile ON peeaMobile.personcenter = p.center
                               AND peeaMobile.personid = p.id
                               AND peeaMobile.name = '_eClub_PhoneSMS'
LEFT JOIN
    person_ext_attrs peeaHome ON peeaHome.personcenter = p.center
                             AND peeaHome.personid = p.id
                             AND peeaHome.name = '_eClub_PhoneHome'
LEFT JOIN
    (
        SELECT
            ck.person_center,
            ck.person_id,
            MAX(ck.checkin_time) AS last_visit_date
        FROM
            checkins ck
        GROUP BY
            ck.person_center, ck.person_id
    ) last_visit ON last_visit.person_center = p.center
                AND last_visit.person_id = p.id
LEFT JOIN
    (
        SELECT
            ck.person_center,
            ck.person_id,
            COUNT(*) AS visit_count
        FROM
            checkins ck
        GROUP BY
            ck.person_center, ck.person_id
    ) total_visits ON total_visits.person_center = p.center
                  AND total_visits.person_id = p.id
WHERE
    p.center IN (:Scope)
    AND p.status IN (1, 3) -- Active and Temporary Inactive only
    AND (
        -- Case 1: Never visited (no checkin records)
        last_visit.last_visit_date IS NULL
        OR
        -- Case 2: Haven't visited for specified number of days (if parameter provided)
        (:Days_Since_Last_Visit IS NOT NULL 
         AND CURRENT_DATE - (TO_TIMESTAMP(last_visit.last_visit_date / 1000) + INTERVAL '10 hours')::date >= :Days_Since_Last_Visit)
    )
ORDER BY 
    c.shortname, p.lastname, p.firstname;