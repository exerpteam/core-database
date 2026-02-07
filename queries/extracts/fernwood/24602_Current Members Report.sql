WITH
    params AS MATERIALIZED
    (
        SELECT
            c.id AS CENTER_ID
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
        (TO_TIMESTAMP(ck.checkin_time / 1000) AT TIME ZONE 'Australia/Sydney')::DATE >= CURRENT_DATE - INTERVAL '7 days'
    GROUP BY
        ck.person_center, ck.person_id
)
SELECT
    p.center || 'p' || p.id AS "Person ID",  -- Person ID
    p.external_id AS "External ID",  -- External ID
    c.shortname AS "Centre",  -- Centre
    CASE
        WHEN p.status = 1 THEN 'Active' 
        WHEN p.status = 2 THEN 'Inactive' 
        WHEN p.status = 3 THEN 'Temporary Inactive'
        WHEN p.status = 4 THEN 'Transferred'  
        ELSE ''
    END AS "Person Status",  -- Person Status
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
    END AS "Person Type",  -- Person Type
    p.firstname AS "First Name",  -- First Name
    p.lastname AS "Last Name",  -- Last Name
    p.address1 AS "Address",  -- Address
    p.city AS "Suburb",  -- Suburb
    p.zipcode AS "Post Code",  -- Post Code
    p.birthdate AS "Birth Date",  -- Birth Date
    peeaHome.txtvalue AS "Home Phone",  -- Home Phone
    peeaMobile.txtvalue AS "Mobile Number",  -- Mobile Number
    peeaEmail.txtvalue AS "Email Address",  -- Email Address
    p.first_active_start_date AS "First Active Start Date",  -- First Active Start Date
    COALESCE(visits_last_7_days.visits_7_days, 0) AS "Visits in Last 7 Days",  -- Visits in Last 7 Days
    TO_CHAR(TO_TIMESTAMP(last_visit.last_visit_date / 1000) + INTERVAL '10 hours', 'DD-MM-YYYY') AS "Last Visit Date",  -- Last Visit Date with time adjustment and formatted as DD-MM-YYYY
    COALESCE(CURRENT_DATE - (TO_TIMESTAMP(last_visit.last_visit_date / 1000) + INTERVAL '10 hours')::date, 0) AS "Days Since Last Visit",  -- Days Since Last Visit
    COUNT(ck.id) AS "Total Number of Visits"  -- Total Number of Visits
FROM 
    persons p 
LEFT JOIN
    checkins CK  -- Changed to LEFT JOIN to include members without check-ins
    ON p.center = ck.person_center
    AND p.id = ck.person_id
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
    AND p.status IN (1, 3)  -- Include only Active (1) and Temporary Inactive (3) statuses
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
    p.first_active_start_date,
    last_visit.last_visit_date,
    visits_last_7_days.visits_7_days
ORDER BY 
    p.center, p.lastname, p.firstname;
