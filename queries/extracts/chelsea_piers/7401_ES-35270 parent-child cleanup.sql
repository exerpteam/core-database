SELECT
    parent.center||'p'||parent.id                 AS parent_id,
    child.center||'p'||child.id                   AS child_id,
    parent.fullname                               AS parent_name,
    child.fullname                                AS child_name,
    parent.birthdate                              AS parent_birthdate,
    child.birthdate                               AS child_birthdate,
    extract(YEAR FROM age(parent.birthdate))::INT AS parent_age,
    extract(YEAR FROM age(child.birthdate))::INT  AS child_age
FROM
    chelseapiers.relatives r
JOIN
    chelseapiers.state_change_log scl
ON
    r.center = scl.center
AND r.id = scl.id
AND r.subid = scl.subid
JOIN
    chelseapiers.employees emp
ON
    emp.center = scl.employee_center
AND emp.id = scl.employee_id
JOIN
    chelseapiers.persons p
ON
    emp.personcenter = p.center
AND emp.personid = p.id
JOIN
    chelseapiers.persons parent
ON
    parent.center = r.center
AND parent.id = r.id
JOIN
    chelseapiers.persons child
ON
    child.center = r.relativecenter
AND child.id = r.relativeid
WHERE
    r.rtype = 18
AND r.status < 2
AND (scl.employee_center, scl.employee_id) IN ((100,1602))
AND scl.entry_end_time IS NULL
    -- This condition make sure that the person we are updating is a CHILD on the new family
    -- configuration which goes hand in hand with the guardian
AND EXISTS
    (
        SELECT
            1
        FROM
            chelseapiers.relatives r1
        WHERE
            r1.center = r.relativecenter
        AND r1.id = r.relativeid
        AND r1.rtype = 22
        AND r1.status < 2 )