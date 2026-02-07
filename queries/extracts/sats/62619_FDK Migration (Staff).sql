SELECT
        p.FULLNAME,
        p.CENTER || 'p' || p.ID AS PersonId,
        email.TXTVALUE AS Email,
        substr(pea.TXTVALUE,4) AS FDK_PersonId,
        emp.CENTER || 'emp' || emp.ID AS EmployeeId,
        SUM(CASE WHEN er.CENTER IS NOT NULL THEN 1 ELSE 0 END) AS NumberOfRoles
FROM SATS.persons p
JOIN SATS.PERSON_EXT_ATTRS pea ON p.CENTER = pea.PERSONCENTER AND p.ID = pea.PERSONID AND pea.NAME = '_eClub_OldSystemPersonId'  AND pea.TXTVALUE LIKE 'fdk%'
LEFT JOIN SATS.PERSON_EXT_ATTRS email ON p.CENTER = email.PERSONCENTER AND p.ID = email.PERSONID AND email.NAME = '_eClub_Email'
LEFT JOIN SATS.EMPLOYEES emp ON p.CENTER = emp.PERSONCENTER AND p.ID = emp.PERSONID
LEFT JOIN SATS.EMPLOYEESROLES er ON er.CENTER = emp.CENTER AND er.ID = emp.ID
WHERE
        p.PERSONTYPE = 2
GROUP BY
        p.FULLNAME,
        p.CENTER,
        p.ID,
        email.TXTVALUE,
        pea.TXTVALUE,
        emp.CENTER,
        emp.ID
ORDER BY 6 DESC
