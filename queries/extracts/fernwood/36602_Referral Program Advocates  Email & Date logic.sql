SELECT DISTINCT
    p.center ||'p'|| p.id AS "Person ID",
    p.external_id AS "Exerp External Id",
    p.firstname AS "First Name",
    p.lastname AS "Last Name",
    Email.txtvalue AS "Email Address",
    LOWER(SUBSTRING(Email.txtvalue FROM '@(.*)')) AS "Email Domain",
    CASE 
        WHEN LOWER(Email.txtvalue) LIKE '%@gmail.%' THEN 'Gmail'
        WHEN LOWER(Email.txtvalue) LIKE '%@yahoo.%' 
          OR LOWER(Email.txtvalue) LIKE '%@icloud.%' 
          OR LOWER(Email.txtvalue) LIKE '%@me.com%' THEN 'Yahoo, iCloud, me.com'
        WHEN LOWER(Email.txtvalue) LIKE '%@outlook.%' 
          OR LOWER(Email.txtvalue) LIKE '%@live.%' 
          OR LOWER(Email.txtvalue) LIKE '%@hotmail.%' 
          OR LOWER(Email.txtvalue) LIKE '%@windowslive.%' THEN 'Outlook, live, hotmail, windowslive'
        ELSE 'Other'
    END AS "Email Provider",
    p.birthdate AS "Birthdate",
    p.center AS "Home Club Id",
    c.name AS "Club Name",
    c.shortname AS "Club Short Name",
    c.state AS "State",
    s.start_date AS "Subscription Start Date",
    s.end_date AS "Subscription End Date",
    p.last_active_start_date AS "Last Active Start Date",
    TO_CHAR(TO_TIMESTAMP(MAX(a.checkin_time) / 1000), 'YYYY-MM-DD') AS "Last Check-in Date",
    CURRENT_DATE - TO_TIMESTAMP(MAX(a.checkin_time) / 1000)::date AS "Days Since Last Check-in",
    CASE 
        WHEN CURRENT_DATE - TO_TIMESTAMP(MAX(a.checkin_time) / 1000)::date <= 45 THEN 'Recent (0-45 days)'
        ELSE 'Older (46+ days)'
    END AS "Check-in Cohort",
    :From AS "Filter From Date",
    :To AS "Filter To Date",
    CASE
        WHEN p.status = 0 THEN 'Lead'
        WHEN p.status = 1 THEN 'Active'
        WHEN p.status = 2 THEN 'Inactive'
        WHEN p.status = 3 THEN 'Temporary Inactive'
        WHEN p.status = 4 THEN 'Transfered'
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
        WHEN p.persontype = 5 THEN 'Onemancorporate'
        WHEN p.persontype = 6 THEN 'Family'
        WHEN p.persontype = 7 THEN 'Senior'
        WHEN p.persontype = 8 THEN 'Guest'
        WHEN p.persontype = 9 THEN 'Child'
        WHEN p.persontype = 10 THEN 'External_Staff'
        ELSE 'Unknown'
    END AS "Person Type",
    pro.name AS "Subscription Name",
    CASE
        WHEN AcceptEmailMarketing.txtvalue = 'true' THEN 'Opted In'
        WHEN AcceptEmailMarketing.txtvalue IS NULL THEN 'Opted In'
        WHEN AcceptEmailMarketing.txtvalue = 'false' THEN 'Opted Out'
    END AS "Marketing Emails",
    Mobile.txtvalue AS "Mobile Number",
    CASE  
        WHEN s.state = 2 THEN 'ACTIVE'
        WHEN s.state = 3 THEN 'ENDED'
        WHEN s.state = 4 THEN 'FROZEN'
        WHEN s.state = 7 THEN 'WINDOW'
        WHEN s.state = 8 THEN 'CREATED'
        ELSE s.state::TEXT
    END AS "Subscription State"
FROM 
    fernwood.persons p
JOIN
    fernwood.subscriptions s
    ON s.owner_center = p.center
    AND s.owner_id = p.id 
    AND s.state IN (2,4)
JOIN
    fernwood.products pro
    ON pro.center = s.SUBSCRIPTIONTYPE_CENTER
    AND pro.ID = s.SUBSCRIPTIONTYPE_ID
JOIN
    fernwood.checkins a
    ON a.person_center = p.center
    AND a.person_id = p.id
JOIN
    fernwood.centers c
    ON c.id = p.center
LEFT JOIN
    fernwood.person_ext_attrs Email
    ON Email.personcenter = p.center
    AND Email.personid = p.id
    AND Email.name = '_eClub_Email'
LEFT JOIN
    fernwood.person_ext_attrs Mobile
    ON Mobile.personcenter = p.center
    AND Mobile.personid = p.id
    AND Mobile.name = '_eClub_PhoneSMS'
LEFT JOIN
    fernwood.person_ext_attrs AcceptEmailMarketing
    ON AcceptEmailMarketing.personcenter = p.center
    AND AcceptEmailMarketing.personid = p.id
    AND AcceptEmailMarketing.name = 'AcceptEmailMarketing'
WHERE
    p.status = 1
    AND p.persontype IN (0, 1, 7)
    AND (AcceptEmailMarketing.txtvalue = 'true' OR AcceptEmailMarketing.txtvalue IS NULL)
    AND Email.txtvalue IS NOT NULL
    AND Email.txtvalue != ''
    AND p.center IN (:Scope)
    AND p.persontype != 6
    AND a.checkin_time >= EXTRACT(EPOCH FROM :From::timestamp) * 1000
    AND a.checkin_time <= EXTRACT(EPOCH FROM :To::timestamp) * 1000
GROUP BY
    p.center, p.id, p.external_id, p.firstname, p.lastname, p.birthdate,
    c.name, c.shortname, c.state, s.start_date, s.end_date, p.last_active_start_date, p.status, p.persontype,
    pro.name, Email.txtvalue, Mobile.txtvalue, AcceptEmailMarketing.txtvalue, s.state
ORDER BY 
    p.center, p.lastname, p.firstname;