-- The extract is extracted from Exerp on 2026-02-08
--  
 SELECT
     C.ID,
     C.NAME,
     emp.CENTER || 'emp' || emp.id AS "Employee Logon",
     (CASE p.STATUS
        WHEN 0 THEN 'LEAD'
        WHEN 1 THEN 'ACTIVE'
        WHEN 2 THEN 'INACTIVE'
        WHEN 3 THEN 'TEMPORARYINACTIVE'
        WHEN 4 THEN 'TRANSFERRED'
        WHEN 5 THEN 'DUPLICATE'
        WHEN 6 THEN 'PROSPECT'
        WHEN 7 THEN 'DELETED'
        WHEN 8 THEN 'ANONYMIZED'
        WHEN 9 THEN 'CONTACT'
        ELSE 'UNKNOWN'
    END) AS person_STATUS,
     p.CENTER || 'p' || p.ID AS "member_id",
     p.FULLNAME,
     STRING_AGG(r.ROLENAME, ' ; ') as Ruoli_Staff,
     email.txtvalue AS "Email", -- Aggiunta virgola
     P.friends_allowance
 FROM EMPLOYEES emp
 JOIN PERSONS p ON p.CENTER = emp.PERSONCENTER AND p.ID = emp.PERSONID -- Spostato sopra email
 LEFT JOIN PERSON_EXT_ATTRS email ON p.center=email.PERSONCENTER AND p.id=email.PERSONID AND email.name='_eClub_Email'
 JOIN EMPLOYEESROLES empr ON empr.CENTER = emp.CENTER AND empr.id = emp.ID
 JOIN ROLES r ON r.ID = empr.ROLEID
 JOIN CENTERS c ON c.id = p.CENTER
 WHERE r.BLOCKED = 0 
     AND r.IS_ACTION = 0
     AND emp.center in (:scope)
 GROUP BY 
     C.ID, C.NAME, emp.CENTER, emp.id, p.STATUS, p.CENTER, p.ID, p.FULLNAME, email.txtvalue, P.friends_allowance;
