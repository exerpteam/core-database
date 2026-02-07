-- This is the version from 2026-02-05
--  
SELECT
    e.NAME,
    longToDate(eu.TIME) last_used,
    p.CENTER || 'p' || p.ID pid,
    emp.CENTER || 'emp' || emp.ID empId,
    p.FIRSTNAME || ' ' || p.LASTNAME emp_name
FROM
    EXTRACT_USAGE eu
JOIN EXTRACT e
ON
    e.ID = eu.EXTRACT_ID
JOIN EMPLOYEES emp
ON
    emp.CENTER = eu.EMPLOYEE_CENTER
    AND emp.ID = eu.EMPLOYEE_ID
JOIN PERSONS p
ON
    p.CENTER = emp.PERSONCENTER
    AND p.ID = emp.PERSONID
WHERE
    e.BLOCKED = 0
order by e.NAME