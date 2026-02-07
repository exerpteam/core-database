SELECT
    "External ID",
    "Clipcard Name",
    "Clip SubID",
    "Price Paid",
    "Sales Date",
    "Class Attended",
    "Class Name",
    "Gym ID",
    "Cost Center",
    "Participation State"
FROM
    (
    WITH
        params AS materialized
        (
            SELECT
                CAST(datetolongC(TO_CHAR(TO_DATE((:fromDate), 'YYYY-MM-DD'), 'YYYY-MM-DD'), c.id) AS
                BIGINT) AS fromDate,
                CAST(datetolongC(TO_CHAR(TO_DATE((:toDate), 'YYYY-MM-DD')+interval '1 day',
                'YYYY-MM-DD'), c.id) AS BIGINT) AS toDate,
                c.id                                        AS CenterID,
                c.external_id                               AS cost_center
            FROM
                centers c
        )
    SELECT
        p.external_id                                       AS "External ID",
        pr.name                                             AS "Clipcard Name",
        cl.subid                                            AS "Clip SubID",
        invl.total_amount/invl.quantity/cl.clips_initial    AS "Price Paid",
        TO_CHAR(longtodateC(inv.trans_time, inv.center), 'DD/MM/YYYY') AS "Sales Date",
        CASE
            WHEN par.state = 'PARTICIPATION'
            THEN TO_CHAR(longtodateC(bo.starttime, bo.center), 'DD/MM/YYYY')
            ELSE NULL
        END             AS "Class Attended",
        bo.name         AS "Class Name",
        bo.center       AS "Gym ID",
        pa.cost_center  AS "Cost Center",
        par.state       AS "Participation State",
        rank() over (partition BY cl.center, cl.id, cl.subid ORDER BY
                ccu.time DESC) ranking
    FROM
        puregym.card_clip_usages ccu
    JOIN
        clipcards cl
    ON
        cl.center = ccu.card_center
    AND cl.id = ccu.card_id
    AND cl.subid = ccu.card_subid
    JOIN
        persons p
    ON
        p.center = cl.owner_center
    AND p.id = cl.owner_id
    JOIN
        products pr
    ON
        pr.center = cl.center
    AND pr.id = cl.id
    JOIN
        invoice_lines_mt invl
    ON
        invl.center = cl.invoiceline_center
    AND invl.id = cl.invoiceline_id
    AND invl.subid = cl.invoiceline_subid
    JOIN
        invoices inv
    ON
        inv.center = invl.center
    AND inv.id = invl.id
    JOIN
        puregym.privilege_usages pu
    ON
        pu.id = ccu.ref
    AND pu.target_service = 'Participation'
    AND pu.privilege_type = 'BOOKING'
    JOIN
        participations par
    ON
        par.center = pu.target_center
    AND par.id = pu.target_id
    JOIN
        bookings bo
    ON
        bo.center = par.booking_center
    AND bo.id = par.booking_id
    JOIN
        params pa
    ON
        pa.centerid = par.center
    WHERE
        par.start_time BETWEEN pa.fromDate AND pa.toDate
    AND par.center IN (:scope) 
    ) t1
WHERE
    t1.ranking = 1