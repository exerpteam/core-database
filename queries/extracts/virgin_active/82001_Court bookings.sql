SELECT
    c.id                                 AS "Center ID",
    c.name                               AS "Center Name",
    bo.name                              AS "Booking Name",
    ac.name                              AS "Activity Name",
    TO_CHAR(longtodateC(bo.starttime, bo.center), 'DD-MM-YYYY HH:MI AM') AS "Start Time",
    TO_CHAR(longtodateC(bo.stoptime, bo.center), 'DD-MM-YYYY HH:MI AM')  AS "End Time",
    sta.center ||'p'|| sta.id            AS "Staff ID",
    sta.fullname                         AS "Staff Name",
    p.fullname                           AS "Participant Name",
    p.center ||'p'|| p.id                AS "Participant ID",
    br.name                              AS "Court"
FROM
    bookings bo
JOIN
    centers c
ON
    c.id = bo.center
JOIN
    participations par
ON
    par.booking_center = bo.center
AND par.booking_id = bo.id
JOIN
    persons p
ON
    p.center = par.participant_center
AND p.id = par.participant_id
JOIN
    virginactive.booking_resource_usage bru
ON
    bru.booking_center = bo.center
AND bru.booking_id = bo.id
AND bru.state = 'ACTIVE'
JOIN
    virginactive.booking_resources br
ON
    br.center = bru.booking_resource_center
AND br.id = bru.booking_resource_id
AND br.type = 'COURT'
JOIN
    virginactive.activity ac
ON
    ac.id = bo.activity
LEFT JOIN
    (
        SELECT
            su.booking_center,
            su.booking_id,
            per.center,
            per.id,
            per.fullname
        FROM
            virginactive.staff_usage su
        JOIN
            persons per
        ON
            per.center = su.person_center
        AND per.id = su.person_id
        WHERE
            su.state = 'ACTIVE' ) sta
ON
    sta.booking_center = bo.center
AND sta.booking_id = bo.id
WHERE
    par.state NOT IN ('CANCELLED')
AND bo.state = 'ACTIVE'
AND bo.starttime >= :currentDate
AND bo.center IN (:scope)
ORDER BY
    c.id,
    bo.starttime