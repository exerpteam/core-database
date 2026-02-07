SELECT
    a.start_time,
    a.booking_id,
    a.class_capacity,
    a.participation_count,
    a.class_time
FROM
    (
        SELECT
            b.starttime                                               AS start_time,
            TO_CHAR(longtodate(p.start_time),'YYYY-MM-DD HH24:MI:SS') AS class_time,
            b.center||'book'||b.id                                    AS booking_id,
            b.class_capacity                                          AS class_capacity,
            COUNT (b.center||'book'||b.id)                            AS participation_count
        FROM
            bookings b
        JOIN
            participations p
        ON
            p.booking_center = b.center
        AND p.booking_id = b.id
        WHERE
            p.state = 'BOOKED'
        AND b.starttime > 1511356900000
        AND b.cancelation_time IS NULL
        AND p.on_waiting_list = 0
        GROUP BY
            b.center||'book'||b.id,
            b.class_capacity,
            b.starttime,
            TO_CHAR(longtodate(p.start_time),'YYYY-MM-DD HH24:MI:SS') ) a
WHERE
    a.participation_count > a.class_capacity