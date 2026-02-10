-- The extract is extracted from Exerp on 2026-02-08
--  
-- Check-In Status Report - Including Failed and Successful Attempts
-- Based on checkins table with checkin_result field for success/failure status

WITH 
    params AS 
    (
        SELECT
            datetolongC(TO_CHAR(CAST(:From AS DATE), 'YYYY-MM-dd HH24:MI'), c.id) AS FromDate,
            c.id AS CENTER_ID,
            CAST((datetolongC(TO_CHAR((CAST(:To AS DATE) + INTERVAL '1 day'), 'YYYY-MM-dd HH24:MI'), c.id) - 1) AS BIGINT) AS ToDate
        FROM
            centers c
    )
SELECT 
    cen.shortname AS "Centre",
    p.center || 'p' || p.id AS "Person ID",
    p.external_id AS "External ID",
    p.firstname AS "First Name",
    p.lastname AS "Last Name",
    TO_CHAR(longtodatetz(ck.checkin_time, cen.time_zone), 'DD-MM-YYYY HH24:MI:SS') AS "Check-In Date/Time",
    CASE 
        WHEN ck.checkin_result = 1 THEN 'SUCCESS'
        WHEN ck.checkin_result = 0 THEN 'FAILED'
        WHEN ck.checkin_result IS NULL THEN 'UNKNOWN'
        ELSE 'OTHER (' || ck.checkin_result || ')'
    END AS "Check-In Result",
    CASE 
        WHEN ck.checkin_result = 1 THEN 'Access Granted'
        WHEN ck.checkin_result = 0 THEN 'Access Denied/Failed'
        ELSE 'Status Unknown'
    END AS "Status Description",
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
    peeaMobile.txtvalue AS "Mobile Number",
    peeaEmail.txtvalue AS "Email Address",
    -- Info codes based on Person Info Code documentation and check-in result
    CASE 
        WHEN ck.checkin_result = 0 AND p.status IN (4,5) THEN 'S' -- Failed + Transferred/Duplicate
        WHEN ck.checkin_result = 0 AND p.status = 2 THEN 'S' -- Failed + Inactive  
        WHEN ck.checkin_result = 0 AND p.status = 3 THEN 'F' -- Failed + Temporary Inactive
        WHEN ck.checkin_result = 0 THEN 'X' -- Failed access (generic)
        WHEN p.status IN (4,5) THEN 'S' -- Transferred/Duplicate
        WHEN p.status = 2 THEN 'S' -- Inactive
        WHEN p.status = 3 THEN 'F' -- Temporary Inactive (Frozen)
        ELSE NULL
    END AS "Info Code",
    -- Count of attempts for this person on this date
    COUNT(*) OVER (PARTITION BY p.center, p.id, DATE(longtodatetz(ck.checkin_time, cen.time_zone))) AS "Daily Attempts",
    -- Count of failed attempts for this person on this date  
    SUM(CASE WHEN ck.checkin_result = 0 THEN 1 ELSE 0 END) OVER (PARTITION BY p.center, p.id, DATE(longtodatetz(ck.checkin_time, cen.time_zone))) AS "Daily Failed Attempts",
    -- Priority level (higher = more attention needed)
    CASE 
        WHEN ck.checkin_result = 0 AND p.status = 1 THEN 5 -- Active member failed access - HIGH PRIORITY
        WHEN ck.checkin_result = 0 AND p.status = 3 THEN 4 -- Temp inactive failed - MEDIUM-HIGH  
        WHEN ck.checkin_result = 0 THEN 3 -- Other failed access - MEDIUM
        WHEN ck.checkin_result = 1 AND p.status != 1 THEN 2 -- Non-active succeeded - LOW-MEDIUM
        WHEN ck.checkin_result = 1 THEN 1 -- Active succeeded - LOW
        ELSE 0
    END AS "Priority Level"

FROM 
    checkins ck
JOIN
    persons p
    ON p.center = ck.person_center
    AND p.id = ck.person_id
JOIN
    centers cen
    ON cen.id = ck.checkin_center
JOIN 
    params 
    ON params.CENTER_ID = ck.checkin_center
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
    ck.checkin_time BETWEEN params.FromDate AND params.ToDate
    AND ck.checkin_center IN (:Scope)
    -- Filter options (uncomment as needed):
    -- AND ck.checkin_result = 0  -- Show only FAILED attempts
    -- AND ck.checkin_result = 1  -- Show only SUCCESSFUL attempts
    -- AND p.persontype NOT IN (2,10)  -- Exclude staff members
    -- AND p.sex != 'C'  -- Exclude companies

ORDER BY 
    "Priority Level" DESC,
    ck.checkin_time DESC,
    cen.shortname,
    p.lastname,
    p.firstname;