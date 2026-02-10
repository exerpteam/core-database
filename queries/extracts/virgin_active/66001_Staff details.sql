-- The extract is extracted from Exerp on 2026-02-08
-- EC-4897 report for staff details, emails and staff groups.
SELECT
        c.id                      AS CENTER_ID,
        c.shortname               AS CENTER_NAME,
        p.center||'p'||p.id       AS P_NUMBER,
        emp.center||'emp'||emp.id AS EMP_NUMBER,
        p.firstname               AS FIRSTNAME,
        p.lastname                AS SURNAME,
        CASE pea.name
            WHEN '_eClub_EmployeeShirtSize'
            THEN 'Shirt size'
            WHEN '_eClub_EmployeeShoeSize'
            THEN 'Shoe size'
            WHEN '_eClub_EmployeeTrouserSize'
            THEN 'Trouser size'
            WHEN '_eClub_StaffExternalId'
            THEN 'Staff External ID'
            WHEN '_eClub_Email'
            THEN 'Email'
            ELSE 'no data'
        END          AS EMP_DETAIL,
        pea.txtvalue AS DETAIL_VALUE,
        NULL         AS STAFF_GROUP_NAME,
        NULL         AS STAFF_GROUP_CENTER_NAME
   FROM
        person_ext_attrs pea
   JOIN
        persons p ON p.center = pea.personcenter AND p.id = pea.personid
   JOIN
        centers c ON c.id = p.center
   JOIN
        employees emp ON p.center = emp.personcenter AND p.id = emp.personid
  WHERE
        pea.name IN ('_eClub_EmployeeShoeSize',
                     '_eClub_EmployeeShirtSize',
                     '_eClub_EmployeeTrouserSize',
                     '_eClub_StaffExternalId',
                     '_eClub_Email')
        AND c.country = 'IT'
        AND emp.blocked IS false
        AND p.status IN (1) ---1 active.
UNION
SELECT
        c.id                      AS CENTER_ID,
        c.shortname               AS CENTER_NAME,
        p.center||'p'||p.id       AS P_NUMBER,
        emp.center||'emp'||emp.id AS EMP_NUMBER,
        p.firstname               AS FIRSTNAME,
        p.lastname                AS SURNAME,
        NULL,
        NULL,
        sg.name AS STAFF_GROUP_NAME,
        CASE
            WHEN psg.scope_type = 'C'
            THEN sgc.shortname
            WHEN psg.scope_type = 'A'
            THEN 'Italy'
        END AS STAFF_GROUP_CENTER_NAME
   FROM
        person_ext_attrs pea
   JOIN
        persons p ON p.center = pea.personcenter AND p.id = pea.personid
   JOIN
        centers c ON c.id = p.center
   JOIN
        employees emp ON p.center = emp.personcenter AND p.id = emp.personid
LEFT JOIN
        person_staff_groups psg ON psg.person_center = p.center AND psg.person_id = p.id
LEFT JOIN
        staff_groups sg ON sg.id = psg.staff_group_id
LEFT JOIN
        centers sgc ON psg.scope_id = sgc.id
  WHERE
        pea.name IN ('_eClub_EmployeeShoeSize',
                     '_eClub_EmployeeShirtSize',
                     '_eClub_EmployeeTrouserSize',
                     '_eClub_StaffExternalId',
                     '_eClub_Email')
        AND c.country = 'IT'
        AND emp.blocked IS false
        AND p.status IN (1) ---1 active.
ORDER BY
        4, 5, 7