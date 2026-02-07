-- Birthday Anniversary Report
-- This report finds members who had a birthday (anniversary) within a specified date range
-- Example: For date range 01/10/2025 - 07/10/2025, will find anyone born on Oct 1-7 of any year

SELECT 
    p.center || 'p' || p.id AS "Exerp ID",
    p.external_id AS "Member ID",
    p.firstname AS "First Name",
    p.lastname AS "Last Name",
    peeaEmail.txtvalue AS "Email Address",
    p.birthdate AS "Birth Date",
    EXTRACT(YEAR FROM CURRENT_DATE) - EXTRACT(YEAR FROM p.birthdate) AS "Age",
    TO_CHAR(p.birthdate, 'DD/MM') AS "Birthday (Day/Month)"
FROM 
    persons p
LEFT JOIN
    person_ext_attrs peeaEmail
    ON peeaEmail.personcenter = p.center
    AND peeaEmail.personid = p.id
    AND peeaEmail.name = '_eClub_Email'
WHERE
    p.center IN (:Scope)
    AND p.birthdate IS NOT NULL
    AND p.status NOT IN (4, 5, 7, 8) -- Exclude Transferred, Duplicate, Deleted, Anonymized
    AND (
        -- Check if the day and month of birthdate falls within the date range
        -- This handles same-year comparisons
        (EXTRACT(MONTH FROM p.birthdate) > EXTRACT(MONTH FROM CAST(:BirthDateFrom AS DATE)) 
         OR (EXTRACT(MONTH FROM p.birthdate) = EXTRACT(MONTH FROM CAST(:BirthDateFrom AS DATE)) 
             AND EXTRACT(DAY FROM p.birthdate) >= EXTRACT(DAY FROM CAST(:BirthDateFrom AS DATE))))
        AND
        (EXTRACT(MONTH FROM p.birthdate) < EXTRACT(MONTH FROM CAST(:BirthDateTo AS DATE))
         OR (EXTRACT(MONTH FROM p.birthdate) = EXTRACT(MONTH FROM CAST(:BirthDateTo AS DATE))
             AND EXTRACT(DAY FROM p.birthdate) <= EXTRACT(DAY FROM CAST(:BirthDateTo AS DATE))))
    )
ORDER BY 
    EXTRACT(MONTH FROM p.birthdate),
    EXTRACT(DAY FROM p.birthdate),
    p.lastname, 
    p.firstname