-- The extract is extracted from Exerp on 2026-02-08
--  
SELECT
    att.center                                                                 AS "Center ID",
    c.name                                                                     AS "Center Name",
    TO_CHAR(longtodateC(att.start_time, att.center), 'YYYY-MM-DD HH:MI:SS AM') AS "Usage Date and Time",
    p.center ||'p'|| p.id AS "Member ID",
    p.fullname AS "Member Name"
FROM
    attends att
JOIN
    booking_resources br
ON
    br.center = att.booking_resource_center
AND br.id = att.booking_resource_id
JOIN
    centers c
ON
    c.id = att.center
JOIN
persons p
ON
p.center = att.person_center
AND p.id = att.person_id
WHERE
    br.name = 'Towel'
AND att.start_time BETWEEN :fromDate AND :toDate
AND att.center IN (:scope)