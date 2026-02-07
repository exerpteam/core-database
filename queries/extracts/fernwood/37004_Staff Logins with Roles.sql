SELECT
    c.name,
    p.center || 'p' || p.id AS PersonId,
    e.center || 'emp' || e.id AS LoginId,
    fernwood.bi_decode_field('PERSONS','STATUS',p.status) as status,
    p.fullname,
    pea.txtvalue AS LegacyId,
    (CASE
        WHEN t1.employee_center IS NULL AND pea.txtvalue IS NOT NULL THEN 'NO'
        WHEN t1.employee_center IS NOT NULL AND pea.txtvalue IS NOT NULL THEN 'YES'
        ELSE NULL
    END) AS Password_Changed,
    e.last_login AS "Last Login",
    TO_CHAR(longtodateC(t2.LastClass,t2.PersonCenter),'YYYY-MM-DD') AS "Last Booking",
    -- Role information using correct table structure
    STRING_AGG(DISTINCT r.rolename, ', ') AS "Roles",
    COUNT(DISTINCT r.id) AS "Role Count"
FROM 
    fernwood.persons p
JOIN
    fernwood.centers c ON p.center = c.id
JOIN
    fernwood.employees e ON p.center = e.personcenter AND p.id = e.personid
-- Add employee roles using correct table structure from your existing extract
LEFT JOIN
    fernwood.employeesroles er
    ON e.center = er.center 
    AND e.id = er.id
LEFT JOIN
    fernwood.roles r
    ON r.id = er.roleid
LEFT JOIN
    fernwood.person_ext_attrs pea ON pea.personcenter = p.center AND pea.personid = p.id AND pea.NAME = '_eClub_OldSystemPersonId'
LEFT JOIN 
(
    SELECT
        eph.employee_center,
        eph.employee_id
    FROM
        fernwood.employee_password_history eph
    GROUP BY 
        eph.employee_center,
        eph.employee_id
    HAVING COUNT(*) > 1
) t1
    ON t1.employee_center = e.center AND t1.employee_id = e.id
LEFT JOIN
(
    SELECT
        Max(b.starttime) AS LastClass                                        
        ,su.person_center AS PersonCenter
        ,su.person_id AS PersonID
    FROM 
        fernwood.bookings b
    JOIN 
        fernwood.staff_usage su
        ON su.booking_center = b.center AND su.booking_id = b.id
    WHERE
        b.state = 'ACTIVE'
        AND
        longtodateC(b.starttime,b.center) < current_date
        AND
        su.person_center in (:scope)
    GROUP BY
        su.person_center
        ,su.person_id
)t2
    ON t2.PersonCenter = p.center AND t2.PersonID = p.id                        
WHERE
    p.center IN (:scope)
GROUP BY
    c.name,
    p.center,
    p.id,
    e.center,
    e.id,
    p.status,
    p.fullname,
    pea.txtvalue,
    t1.employee_center,
    e.last_login,
    t2.LastClass,
    t2.PersonCenter
ORDER BY
    c.name, p.fullname