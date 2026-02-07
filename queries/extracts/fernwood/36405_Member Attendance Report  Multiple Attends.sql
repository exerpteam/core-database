-- Member Attendance Report with Multiple Swipes
-- Description: Tracks member check-ins and flags members with multiple swipes on the same day
-- Parameters: :From (start date), :To (end date), :Scope (center selection)

WITH
    params AS
    (
        SELECT
            /*+ materialize */
            datetolongC(TO_CHAR(CAST(:From AS DATE), 'YYYY-MM-dd HH24:MI'),c.id) AS FromDate,
            c.id AS CENTER_ID,
            CAST((datetolongC(TO_CHAR((CAST(:To AS DATE) + INTERVAL '1 day'), 'YYYY-MM-dd HH24:MI'),c.id) - 1) AS BIGINT) AS ToDate
        FROM
            centers c
    ),
    member_checkins AS
    (
        SELECT
            ck.person_center,
            ck.person_id,
            ck.checkin_time,
            TO_CHAR(longtodateC(ck.checkin_time, ck.checkin_center), 'YYYY-MM-DD') AS checkin_date,
            TO_CHAR(longtodateC(ck.checkin_time, ck.checkin_center), 'HH24:MI:SS') AS checkin_time_formatted,
            ROW_NUMBER() OVER (
                PARTITION BY ck.person_center, ck.person_id, 
                TO_CHAR(longtodateC(ck.checkin_time, ck.checkin_center), 'YYYY-MM-DD')
                ORDER BY ck.checkin_time
            ) AS daily_swipe_number
        FROM
            checkins ck
        JOIN
            params ON params.CENTER_ID = ck.checkin_center
        WHERE
            ck.checkin_time BETWEEN params.FromDate AND params.ToDate
    ),
    daily_swipe_counts AS
    (
        SELECT
            person_center,
            person_id,
            checkin_date,
            COUNT(*) AS total_swipes_per_day,
            MIN(checkin_time_formatted) AS first_swipe_time,
            MAX(checkin_time_formatted) AS last_swipe_time
        FROM
            member_checkins
        GROUP BY
            person_center, person_id, checkin_date
    )
SELECT DISTINCT
    c.shortname AS "Centre Name",
    p.center ||'p'|| p.id AS "Person ID",
    p.external_id AS "External ID",
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
    peeaMobile.txtvalue AS "Mobile Number",
    peeaEmail.txtvalue AS "Email Address",
    mc.checkin_date AS "Check-in Date",
    mc.checkin_time_formatted AS "Check-in Time",
    mc.daily_swipe_number AS "Swipe Number for Day",
    dsc.total_swipes_per_day AS "Total Daily Swipes",
    dsc.first_swipe_time AS "First Swipe Time",
    dsc.last_swipe_time AS "Last Swipe Time",
    CASE 
        WHEN dsc.total_swipes_per_day > 1 THEN 'MULTIPLE SWIPES'
        ELSE 'SINGLE SWIPE'
    END AS "Multiple Swipe Flag",
    CASE 
        WHEN dsc.total_swipes_per_day > 2 THEN '> 3 ATTENDS'
        WHEN dsc.total_swipes_per_day = 2 THEN '2 ATTENDS'
        ELSE 'NORMAL'
    END AS "Swipe Frequency Category"
FROM
    member_checkins mc
JOIN
    daily_swipe_counts dsc
    ON mc.person_center = dsc.person_center
    AND mc.person_id = dsc.person_id
    AND mc.checkin_date = dsc.checkin_date
JOIN
    persons p
    ON p.center = mc.person_center
    AND p.id = mc.person_id
JOIN
    centers c
    ON c.id = p.center
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
    AND p.persontype != 2  -- Exclude staff members
    AND p.persontype != 6  -- Exclude family members (optional - remove if needed)
    AND dsc.total_swipes_per_day > 1  -- ONLY show members with multiple swipes per day
ORDER BY
    c.shortname,
    mc.checkin_date DESC,
    dsc.total_swipes_per_day DESC,
    p.lastname,
    p.firstname,
    mc.daily_swipe_number;