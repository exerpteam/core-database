WITH
    params AS materialized
    (
        SELECT 
            (($$from_date$$::DATE - to_date ('1970-01-01', 'yyyy-MM-dd'))::bigint)*1000*60*60*24
            AS from_date,
            (($$to_date$$::DATE - to_date ('1970-01-01','yyyy-MM-dd'))::bigint)*1000*60*60*24
            AS to_date
    )
SELECT
    emp.center||'emp'||emp.id                   AS employee_id,
    email.txtvalue                              AS employee_email,
    longtodatec(MAX(pla.entry_time),emp.center) AS last_login,
    COUNT(pla.entry_time)                       AS login_attempts
FROM
    params,
    employee_login_attempts pla
JOIN
    employees emp
ON
    emp.center = pla.employee_center
AND emp.id = pla.employee_id
JOIN
    person_ext_attrs email
ON
    email.personcenter = emp.personcenter
AND email.personid = emp.personid
AND email.name = '_eClub_Email'
WHERE
    pla.entry_time > params.from_date
AND pla.entry_time < params.to_date
AND emp.center IN ($$scope$$)
GROUP BY
    emp.center,
    emp.id,
    email.txtvalue