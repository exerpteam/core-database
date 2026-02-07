SELECT
        DISTINCT
        p.CENTER || 'p' || p.ID,
        (CASE
                WHEN emp.CENTER IS NULL THEN NULL
                ELSE emp.CENTER || 'emp' || emp.ID
        END)  AS EmployeeId,
        p.CENTER AS HomeCenter,
        email.TXTVALUE AS Email,
        mobile.TXTVALUE AS Mobile,
        p.STATUS
FROM PERSONS p
JOIN EMPLOYEES emp ON emp.PERSONCENTER = p.CENTER AND emp.PERSONID = p.ID AND emp.BLOCKED = 0
LEFT JOIN PERSON_EXT_ATTRS email ON email.PERSONCENTER = p.CENTER AND email.PERSONID = p.ID AND email.NAME = '_eClub_Email'
LEFT JOIN PERSON_EXT_ATTRS mobile ON mobile.PERSONCENTER = p.CENTER AND mobile.PERSONID = p.ID AND mobile.NAME = '_eClub_PhoneSMS'
WHERE   
        p.PERSONTYPE = 2
        AND p.STATUS NOT IN (4,5,7)