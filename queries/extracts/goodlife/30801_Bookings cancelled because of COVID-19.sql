-- The extract is extracted from Exerp on 2026-02-08
--  
SELECT
    a.name                               AS activity_name,
    c.name                               AS center_name,
    c.id                                 AS center_id,
    longtodateC(b.starttime, b.center)   AS starttime,
    longtodateC(b.stoptime, b.center)    AS endtime,
    b.center ||'bk'||b.id                AS booking_id,
    su.person_center ||'p'||su.person_id AS staff_id,
    emp.external_id                      AS staff_external_id,
    emp.fullname                         AS staff_name
    
FROM
    bookings b
left JOIN goodlife.participations part ON b.center = part.booking_center AND b.id = part.booking_id
left JOIN
    staff_usage su
ON
    b.center = su.booking_center
AND b.id = su.booking_id

left JOIN
    activity a
ON
    b.activity = a.id
JOIN
    persons emp
ON
    su.person_center = emp.center
AND su.person_id = emp.id
JOIN
    centers c
ON
    b.center = c.id
WHERE
    b.cancellation_reason = 'COVID-19 measures'