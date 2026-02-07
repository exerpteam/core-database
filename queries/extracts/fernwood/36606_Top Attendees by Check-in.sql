-- Top Attendees Check-ins Extract
-- This extract shows members ranked by their check-in frequency within a specified date range

WITH
    params AS
    (
        SELECT
            /*+ materialize */
            datetolongC(TO_CHAR(CAST(:From AS DATE), 'YYYY-MM-dd HH24:MI'), c.id) AS FromDate,
            c.id AS CENTER_ID,
            CAST((datetolongC(TO_CHAR((CAST(:To AS DATE) + INTERVAL '1 day'), 'YYYY-MM-dd HH24:MI'), c.id) - 1) AS BIGINT) AS ToDate
        FROM
            centers c
    ),
    checkin_summary AS
    (
        SELECT
            ck.person_center,
            ck.person_id,
            COUNT(*) AS total_checkins,
            MIN(ck.checkin_time) AS first_checkin_in_period,
            MAX(ck.checkin_time) AS last_checkin_in_period
        FROM
            checkins ck
        JOIN
            params p
            ON p.CENTER_ID = ck.person_center
        WHERE
            ck.checkin_time BETWEEN p.FromDate AND p.ToDate
        GROUP BY
            ck.person_center,
            ck.person_id
    )
SELECT
    p.center || 'p' || p.id AS "Member ExerpID",
    p.firstname AS "First Name",
    p.lastname AS "Last Name",
    peeaEmail.txtvalue AS "Member Email",
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
    cs.total_checkins AS "Number of Check-Ins",
    CAST(longtodatec(cs.first_checkin_in_period, cs.person_center) AS DATE) AS "First Check-In Date",
    CAST(longtodatec(cs.last_checkin_in_period, cs.person_center) AS DATE) AS "Last Check-In Date",
    c.shortname AS "Centre"
FROM
    checkin_summary cs
JOIN
    persons p
    ON p.center = cs.person_center
    AND p.id = cs.person_id
JOIN
    centers c
    ON c.id = p.center
LEFT JOIN
    person_ext_attrs peeaEmail
    ON peeaEmail.personcenter = p.center
    AND peeaEmail.personid = p.id
    AND peeaEmail.name = '_eClub_Email'
WHERE
    p.center IN (:Scope)
    AND p.status IN (1, 2, 3) -- Active, Inactive, Temporary Inactive (exclude deleted, duplicates, etc.)
    AND p.persontype NOT IN (2, 10) -- Exclude Staff (2) and External Staff (10)
ORDER BY
    cs.total_checkins DESC,
    p.lastname,
    p.firstname;