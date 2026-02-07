SELECT
    t1.centerid      AS "Center ID",
    t1.centername    AS "Center Name",
    t1.bookingId     AS "Booking ID",
    t1.name          AS "Booking Name",
    t1.starttime     AS "Start Date/Time",
    COUNT(*)         AS "Participants",
    COUNT(*) FILTER (WHERE t1.sex = 'F') AS "Female Participants",
    COUNT(*) FILTER (WHERE t1.sex = 'M') AS "Male Participants",
    SUM(t1.printed)  AS "Tickets Printed"
FROM
(
    WITH
        params AS materialized
        (
            SELECT
                CAST(datetolongC(TO_CHAR(TO_DATE((:fromDate), 'YYYY-MM-DD'), 'YYYY-MM-DD'), c.id) AS BIGINT) AS fromDate,
                CAST(datetolongC(TO_CHAR(TO_DATE((:toDate), 'YYYY-MM-DD') + interval '1 day', 'YYYY-MM-DD'), c.id) AS BIGINT) AS toDate,
                c.id   AS CenterID,
                c.name AS CenterName
            FROM
                centers c
        )
    SELECT
        params.CenterID,
        params.CenterName,
        bo.center || 'book' || bo.id AS bookingId,
        bo.name,
        TO_CHAR(longtodateC(bo.starttime, bo.center), 'DD-MM-YYYY HH24:MI') AS starttime,
        par.participant_center,
        par.participant_id,
        p.sex,
        CASE
            WHEN par.print_time IS NULL THEN 0
            ELSE 1
        END AS printed
    FROM
        bookings bo
    JOIN
        params
    ON
        params.centerid = bo.center
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
    WHERE
        bo.starttime BETWEEN params.fromDate AND params.toDate
    AND par.state = 'PARTICIPATION'
    AND bo.center IN (:scope)
) t1
GROUP BY
    t1.centerid,
    t1.centername,
    t1.bookingId,
    t1.name,
    t1.starttime
ORDER BY
    t1.centerid,
    t1.starttime,
    t1.name;
