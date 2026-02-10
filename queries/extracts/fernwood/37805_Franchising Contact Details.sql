-- The extract is extracted from Exerp on 2026-02-08
--  
SELECT 
    p.center ||'p'|| p.id AS "Person ID",
    p.external_id AS "External ID",
    Email.txtvalue AS "Email Address",
    p.firstname AS "First Name",
    p.lastname AS "Last Name",
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
    END AS "Person Status"
FROM
    persons p
LEFT JOIN
    person_ext_attrs Email
    ON Email.personcenter = p.center
    AND Email.personid = p.id
    AND Email.name = '_eClub_Email'
WHERE
    p.center IN (:Scope)
    AND p.status NOT IN (4, 5, 7, 8)  -- Exclude Transferred, Duplicate, Deleted, Anonymized
ORDER BY
    p.lastname, p.firstname;