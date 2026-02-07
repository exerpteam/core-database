SELECT
    emp.CENTER || 'emp' || emp.ID             emp_number
  , emp.PERSONCENTER || 'emp' || emp.PERSONID user_pid
  , p.FULLNAME                                user_full_name
  , longToDateC(ex.TIME,emp.CENTER)            Run_date
  , ex.EXTRACT_ID  Extract_ID
FROM
    EXTRACT_USAGE ex
JOIN
    EXTRACT e
ON
    e.id = ex.EXTRACT_ID
JOIN
    EMPLOYEES emp
ON
    emp.CENTER = ex.EMPLOYEE_CENTER
    AND emp.id = ex.EMPLOYEE_id
JOIN
    PERSONS p
ON
    p.CENTER = emp.PERSONCENTER
    AND p.ID = emp.PERSONID
WHERE
    ex.TIME BETWEEN $$from_date$$ AND (
        $$to_date$$ + (1000 * 60 * 60 * 24 -1 ))