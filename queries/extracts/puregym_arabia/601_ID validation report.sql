SELECT
        p.firstname AS "First Name",
        p.middlename AS "Middle Name",
        p.lastname AS "Last Name",
        p.birthdate AS "D.O.B",
        p.external_id AS "External ID",
        p.center || 'p' || p.id as "P Number",
        p.center AS "Center ID",
        c.name AS "Club",
        creation.txtvalue AS "Creation Date",
        (CASE
                WHEN pass.txtvalue IS NOT NULL THEN 'Passport ID'
                WHEN p.national_id IS NOT NULL THEN 'National ID'
                WHEN p.resident_id IS NOT NULL THEN 'Resident ID'
                ELSE NULL
        END) AS "Document Type",
        (CASE
                WHEN pass.txtvalue IS NOT NULL THEN pass.txtvalue
                WHEN p.national_id IS NOT NULL THEN p.national_id
                WHEN p.resident_id IS NOT NULL THEN p.resident_id
                ELSE NULL
        END) AS "Document ID",
        pea.txtvalue AS "Validation Status"
FROM
        puregym_arabia.persons p
JOIN
        puregym_arabia.person_ext_attrs pea ON p.center = pea.personcenter AND p.id = pea.personid AND pea.name = 'Validation'
JOIN
        puregym_arabia.person_ext_attrs creation ON p.center = creation.personcenter AND p.id = creation.personid AND creation.name = 'CREATION_DATE'  
JOIN
        puregym_arabia.centers c ON p.center = c.id
LEFT JOIN
        puregym_arabia.person_ext_attrs pass ON p.center = pass.personcenter AND p.id = pass.personid AND pass.name = '_eClub_PassportNumber'
WHERE
        p.status NOT IN (4,5,7,8)
		AND p.center IN (:Scope)
		AND pea.txtvalue IN (:Validation)
		AND TO_DATE(creation.txtvalue,'YYYY-MM-DD') between :FromDate and :ToDate