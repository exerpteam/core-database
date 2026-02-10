-- The extract is extracted from Exerp on 2026-02-08
-- https://clublead.atlassian.net/browse/EC-1764
SELECT
        c.name,
        p.center || 'p' || p.id AS PersonId,
        e.center || 'emp' || e.id AS LoginId,
        bi_decode_field('PERSONS','STATUS',p.status) as status,
        p.fullname,
        pea.txtvalue AS LegacyId,
        (CASE
                WHEN t1.employee_center IS NULL AND pea.txtvalue IS NOT NULL THEN 'NO'
                WHEN t1.employee_center IS NOT NULL AND pea.txtvalue IS NOT NULL THEN 'YES'
                ELSE NULL
        END) AS Password_Changed
        ,e.last_login AS "Last Login"
        ,TO_CHAR(longtodateC(t2.LastClass,t2.PersonCenter),'YYYY-MM-DD') AS "Last Booking"
FROM 
        persons p
JOIN
        centers c ON p.center = c.id
JOIN
        employees e ON p.center = e.personcenter AND p.id = e.personid
LEFT JOIN
        person_ext_attrs pea ON pea.personcenter = p.center AND pea.personid = p.id AND pea.NAME = '_eClub_OldSystemPersonId'
LEFT JOIN 
(
        SELECT
                eph.employee_center,
                eph.employee_id
        FROM
                employee_password_history eph
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
                bookings b
        JOIN 
                staff_usage su
                ON su.booking_center = b.center AND su.booking_id = b.id
        WHERE
                b.state = 'ACTIVE'
                AND
                longtodateC(b.starttime,b.center) < current_date
        GROUP BY
                su.person_center
                ,su.person_id
)t2
        ON t2.PersonCenter = p.center AND t2.PersonID = p.id                        
WHERE
	p.center IN (:scope)

              

                