-- The extract is extracted from Exerp on 2026-02-08
--  
SELECT
    longtodateC(b.starttime,b.center)     AS starttime,
    longtodateC(b.stoptime,b.center)      AS stoptime,
    longtodateC(b.creation_time,b.center) AS CreationTime,
    b.center ||'bk'||b.id                 AS bookingid,
    b.name,
    per.fullname            AS TRAINER,
    per.center||'p'||per.id AS Trainer_personid
FROM
    bookings b
JOIN
    activity a
ON
    b.activity = a.id
LEFT JOIN
    STAFF_USAGE su
ON
    su.BOOKING_CENTER = b.center
AND su.BOOKING_ID = b.id
AND su.state = 'ACTIVE'
LEFT JOIN
    persons per
ON
    per.CENTER = su.PERSON_CENTER
AND per.ID = su.PERSON_ID
JOIN
    centers c
ON
    c.id = b.center

WHERE
    a.name IN ($$activity_name$$)
AND b.state = 'ACTIVE'
ORDER BY
    starttime
    Limit 1000