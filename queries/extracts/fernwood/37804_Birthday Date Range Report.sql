-- The extract is extracted from Exerp on 2026-02-08
--  
-- Birthday Date Range Report
-- This report show members whose birthdate falls within a specified date range

SELECT 
    p.center || 'p' || p.id AS "Exerp ID",
    p.external_id AS "Member ID",
    p.firstname AS "First Name",
    p.lastname AS "Last Name",
    peeaEmail.txtvalue AS "Email Address",
    p.birthdate AS "Birth Date"
FROM 
    persons p
LEFT JOIN
    person_ext_attrs peeaEmail
    ON peeaEmail.personcenter = p.center
    AND peeaEmail.personid = p.id
    AND peeaEmail.name = '_eClub_Email'
WHERE
    p.center IN (:Scope)
    AND p.birthdate BETWEEN :BirthDateFrom AND :BirthDateTo
    AND p.status NOT IN (4, 5, 7, 8) -- Exclude Transferred, Duplicate, Deleted, Anonymized
ORDER BY 
    p.birthdate, p.lastname, p.firstname