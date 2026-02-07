SELECT
    e.NAME,
    longToDate(eu.TIME) last_used,
    p.CENTER || 'p' || p.ID pid,
    emp.CENTER || 'emp' || emp.ID empId,
    p.FIRSTNAME || ' ' || p.LASTNAME emp_name
FROM
    SATS.EXTRACT_USAGE eu
JOIN SATS.EXTRACT e
ON
    e.ID = eu.EXTRACT_ID
JOIN SATS.EMPLOYEES emp
ON
    emp.CENTER = eu.EMPLOYEE_CENTER
    AND emp.ID = eu.EMPLOYEE_ID
JOIN SATS.PERSONS p
ON
    p.CENTER = emp.PERSONCENTER
    AND p.ID = emp.PERSONID
WHERE
    e.BLOCKED = 0
order by e.NAME