WITH
    params AS
    (
        SELECT
            CAST(datetolongC(TO_CHAR(TO_DATE(:from_date, 'YYYY-MM-DD'), 'YYYY-MM-DD'), c.id) AS
            BIGINT) AS from_date,
            CAST(datetolongC(TO_CHAR(TO_DATE(:to_date, 'YYYY-MM-DD'), 'YYYY-MM-DD'), c.id) AS
            BIGINT)+86400000 AS to_date ,
            c.id             AS center_id,
            c.name
        FROM
            centers c
    )
SELECT
    TO_CHAR(longtodateC(bo.starttime, bo.center), 'YYYY-MM-DD') AS "Date",
	TO_CHAR(longtodateC(bo.starttime, bo.center), 'HH12:MI AM') AS "Start time",
    params.name                                                 AS "Center name",
    bo.name                                                     AS "Session name",
    su.person_center ||'p'|| su.person_id                       AS "Staff person ID",
    sta.fullname                                                AS "Staff name"
FROM
    bookings bo
JOIN
    params
ON
    params.center_id = bo.center
JOIN
    activity ac
ON
    ac.id = bo.activity
LEFT JOIN
    staff_usage su
ON
    su.booking_center = bo.center
AND su.booking_id = bo.id
JOIN
    persons sta
ON
    sta.center = su.person_center
AND sta.id = su.person_id
WHERE
    ac.activity_type = 4
AND ac.activity_group_id = 3
AND bo.state = 'CANCELLED'
AND bo.starttime BETWEEN params.from_date AND params.to_date
AND bo.center IN (:scope)
ORDER BY
su.person_center,
su.person_id,
bo.starttime