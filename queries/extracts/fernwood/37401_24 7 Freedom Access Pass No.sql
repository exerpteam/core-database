SELECT DISTINCT
    p.center || 'p' || p.id AS "Person ID",
    p.external_id AS "External ID",
    p.firstname AS "First Name",
    p.lastname AS "Last Name",
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
    peeaEmail.txtvalue AS "Email Address",
    peeaMobile.txtvalue AS "Mobile Number",
    peeaHome.txtvalue AS "Home Phone",
    COALESCE(freedompass.txtvalue, 'No Value') AS "FREEDOMPASS24HOURACCESS Value"
FROM 
    persons p
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
    person_ext_attrs freedompass
    ON freedompass.personcenter = p.center
    AND freedompass.personid = p.id
    AND freedompass.name = 'FREEDOMPASS24HOURACCESS'
WHERE
    p.center IN (:Scope)
    AND p.status NOT IN (4, 5, 7, 8) -- Exclude Transferred, Duplicate, Deleted, Anonymized
    AND (
        freedompass.txtvalue IS NULL 
        OR freedompass.txtvalue = 'N' 
        OR freedompass.txtvalue = ''
        OR TRIM(freedompass.txtvalue) = ''
    )
ORDER BY 
    c.shortname, p.lastname, p.firstname;