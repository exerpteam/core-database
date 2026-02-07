WITH
    params AS
    (
        SELECT
            CAST(datetolongC(TO_CHAR(TO_DATE(:from_date, 'YYYY-MM-DD'), 'YYYY-MM-DD'), c.id) AS BIGINT)    AS from_date,
            CAST(datetolongC(TO_CHAR(TO_DATE(:to_date, 'YYYY-MM-DD'), 'YYYY-MM-DD'), c.id) AS BIGINT)+86400000 AS to_date ,
            c.id AS center_id
        FROM
            centers c
    )
SELECT
    t.start_date     AS "Date",
    t.center_name    AS "Center",
    t.activity_group AS "Activity Group",
    COUNT(*)         AS "Sessions"
FROM
    (
        SELECT
            c.name                                                      AS center_name,
            TO_CHAR(longtodateC(bo.starttime, bo.center), 'YYYY-MM-DD') AS Start_date,
            bo.name                                                     AS Booking_name,
            ag.name                                                     AS Activity_group
        FROM
            bookings bo
        JOIN
            params
        ON
            params.center_id = bo.center
        JOIN
            centers c
        ON
            c.id = bo.center
        JOIN
            activity ac
        ON
            ac.id = bo.activity
        JOIN
            activity_group ag
        ON
            ag.id = ac.activity_group_id
        JOIN
            (
                SELECT DISTINCT
                ON
                    (
                        su.booking_center, su.booking_id) *
                FROM
                    staff_usage su
                ORDER BY
                    su.booking_center,
                    su.booking_id,
                    su.cancellation_time DESC ) su
        ON
            su.booking_center = bo.center
        AND su.booking_id = bo.id
        JOIN
            persons sta
        ON
            sta.center = su.person_center
        AND sta.id = su.person_id
        JOIN
            participations par
        ON
            par.booking_center = bo.center
        AND par.booking_id = bo.id
        JOIN
            privilege_usages pu
        ON
            pu.target_center = par.center
        AND pu.target_id = par.id
        AND pu.target_service = 'Participation'
        JOIN
            clipcards cl
        ON
            cl.center = pu.source_center
        AND cl.id = pu.source_id
        AND cl.subid = pu.source_subid
        JOIN
            invoice_lines_mt invl
        ON
            invl.center = cl.invoiceline_center
        AND invl.id = cl.invoiceline_id
        AND invl.subid = cl.invoiceline_subid
        JOIN
            products pr
        ON
            pr.center = cl.center
        AND pr.id = cl.id
        JOIN
            product_and_product_group_link prgl
        ON
            prgl.product_center = pr.center
        AND prgl.product_id = pr.id
        JOIN
            persons p
        ON
            p.center = par.participant_center
        AND p.id = par.participant_id
        WHERE
            ac.activity_type = 4
        AND (
                pu.state = 'USED'
            OR  (
                    pu.state = 'CANCELLED'
                AND pu.misuse_state = 'PUNISHED'))
        AND bo.starttime >= params.from_date
        AND bo.starttime <= params.to_date
        AND bo.center IN (:scope)
        AND prgl.product_group_id IN (603,604)
        ORDER BY
            su.person_center,
            su.person_id,
            bo.starttime ) t
GROUP BY
    t.start_date,
    t.center_name,
    t.activity_group