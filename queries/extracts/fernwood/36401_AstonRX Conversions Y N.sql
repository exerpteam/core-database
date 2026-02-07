WITH params AS
(
    SELECT
        datetolongC(TO_CHAR(CAST(:From AS DATE), 'YYYY-MM-dd HH24:MI'),c.id) AS FromDate,
        c.id AS CENTER_ID,
        CAST((datetolongC(TO_CHAR((CAST(:To AS DATE) + INTERVAL '1 day'), 'YYYY-MM-dd HH24:MI'),c.id) - 1) AS BIGINT) AS ToDate
    FROM
        centers c
)
SELECT 
    p.center || 'p' || p.id AS "Person ID",
    c.shortname AS "Club Name",
    p.firstname AS "First Name",
    p.lastname AS "Last Name",
    pea_email.txtvalue AS "Email Address",
    p.external_id AS "External ID",
    CASE p.status 
        WHEN 0 THEN 'Lead' 
        WHEN 1 THEN 'Active' 
        WHEN 2 THEN 'Inactive' 
        WHEN 3 THEN 'Temporary Inactive' 
        WHEN 4 THEN 'Transferred' 
        WHEN 5 THEN 'Duplicate' 
        WHEN 6 THEN 'Prospect' 
        WHEN 7 THEN 'Deleted' 
        WHEN 8 THEN 'Anonymized' 
        WHEN 9 THEN 'Contact' 
        ELSE 'Unknown' 
    END AS "Person Status",
    pea_subscribed.txtvalue AS "AstonRX - Subscribed",
    pea_dt.txtvalue AS "AstonRX - Subscribed DT",
    pea_email_status.txtvalue AS "AstonRX",
    CASE 
        WHEN pea_subscribed.txtvalue = 'yes' THEN 'Yes'
        ELSE 'No'
    END AS "Converted"
FROM 
    persons p
JOIN 
    centers c ON c.id = p.center
JOIN 
    params ON params.CENTER_ID = p.center
LEFT JOIN 
    person_ext_attrs pea_email_status
    ON pea_email_status.personcenter = p.center
    AND pea_email_status.personid = p.id
    AND pea_email_status.name = 'astonrx'
LEFT JOIN 
    person_ext_attrs pea_subscribed
    ON pea_subscribed.personcenter = p.center
    AND pea_subscribed.personid = p.id
    AND pea_subscribed.name = 'AstonRXSubscribed'
LEFT JOIN 
    person_ext_attrs pea_dt
    ON pea_dt.personcenter = p.center
    AND pea_dt.personid = p.id
    AND pea_dt.name = 'AstonRXSubscribedDT'
LEFT JOIN 
    person_ext_attrs pea_email
    ON pea_email.personcenter = p.center
    AND pea_email.personid = p.id
    AND pea_email.name = '_eClub_Email'
WHERE 
    p.center IN (:Scope)
    AND pea_email_status.txtvalue IN (:AstonRX)
    AND pea_email_status.last_edit_time BETWEEN params.FromDate AND params.ToDate
    AND p.status NOT IN (5, 7, 8)
ORDER BY 
    c.shortname, 
    p.lastname, 
    p.firstname;