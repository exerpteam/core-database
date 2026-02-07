SELECT
    -- PERSON DATA
    p.FULLNAME AS FullName,
    p.CENTER || 'p' || p.ID AS Person_ID,
    CASE p.STATUS
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
    END AS Person_STATUS,

    -- EMPLOYEE DATA
    emp.CENTER || 'emp' || emp.ID AS Employee_ID,
    CASE emp.BLOCKED
        WHEN 1 THEN 'RUOLO_BLOCCATO'
        WHEN 0 THEN 'RUOLO_ATTIVO'
        ELSE 'NESSUN RUOLO INSERITO'
    END AS Emp_STATUS,
    emp.last_login,

    -- CLUB / CENTER
    c.SHORTNAME AS Emp_Club,

    -- ROLE
    r.IS_ACTION,
    r.ROLENAME

FROM PERSONS p

LEFT JOIN EMPLOYEES emp
       ON emp.PERSONCENTER = p.CENTER
      AND emp.PERSONID = p.ID

LEFT JOIN EMPLOYEESROLES empr
       ON empr.CENTER = emp.CENTER
      AND empr.id = emp.ID

LEFT JOIN ROLES r
       ON r.ID = empr.ROLEID

LEFT JOIN CENTERS c
       ON c.id = emp.CENTER

LEFT JOIN SUBSCRIPTIONS s
       ON p.center = s.OWNER_CENTER
      AND p.id = s.OWNER_ID
      AND s.state IN (2,4,8)

WHERE
    p.CENTER IN (:scope)
    AND p.STATUS IN (0,1,2,3,6,7,9)
    AND p.persontype = 2

GROUP BY
    p.FULLNAME,
    p.CENTER || 'p' || p.ID,
    p.STATUS,
    emp.CENTER || 'emp' || emp.ID,
    emp.BLOCKED,
    emp.last_login,
    c.SHORTNAME,
    r.IS_ACTION,
    r.ROLENAME

ORDER BY
    FullName ASC;
