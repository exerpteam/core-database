SELECT
    t.centername,
    t.booking_center||'book'||t.booking_id                                      AS bookingid,
    TO_CHAR(longtodateC(t.booking_start,t.booking_center),'YYYY-MM-DD HH24:MI') AS
                                                    booking_starttime,
    longtodateC(t.booking_stop,t.booking_center) AS booking_stop,
    p.external_id                                AS staff_external_id,
    p.fullname as staff_name,
    mem.external_id                              AS mem_externalid,
    t.bk_name,
    t.bk_starttime,
    t.bk_stoptime
FROM
    (
        WITH
            params AS
            (
                SELECT
                    datetolongTZ(TO_CHAR(to_date(TO_CHAR(now(),'yyyy-mm-dd'),'yyyy-mm-dd'),
                    'YYYY-MM-DD HH24:MI:SS' ), c.time_zone) AS ep_today,
                    --datetolongc(TO_CHAR(to_date('2020-06-12', 'YYYY-MM-DD HH24:MI:SS'),'YYYY-MM-DD HH24:MI:SS'), c.id) + (24*3600*1000) - 1 AS ep_future,
                   datetolongc(TO_CHAR(to_date($$to_date$$, 'YYYY-MM-DD HH24:MI:SS'),'YYYY-MM-DD HH24:MI:SS'), c.id) + (24*3600*1000) - 1 AS ep_future,
                    c.id                                                 AS centerid,
                    c.name                                               AS centername
                FROM
                    centers c
            )
        SELECT
            EXTRACT (DAY FROM LONGTODATEc(B.starttime,B.CENTER) ) AS bk_starttime,
            EXTRACT (DAY FROM LONGTODATEc(B.stoptime,B.CENTER) )  AS bk_stoptime,
            b.state                                               AS bk_state,
            B.CENTER                                              AS BOOKING_CENTER,
            B.ID                                                  AS BOOKING_ID,
            b.starttime                                           AS booking_start,
            b.stoptime                                            AS booking_stop,
            b.name                                                AS bk_name,
            centername
        FROM
            BOOKINGS B
        JOIN
            params
        ON
            b.center = params.centerid
        JOIN
            activity a
        ON
            b.activity =a.id
        WHERE
            B.STARTTIME BETWEEN params.ep_today AND params.ep_future
        AND a.activity_type NOT IN (6,7)
        AND B.STATE <>'CANCELLED' )t
LEFT JOIN
    lifetime.staff_usage su
ON
    t.BOOKING_CENTER = su.booking_center
AND t.BOOKING_ID = su.booking_id
AND su.state = 'ACTIVE'

LEFT JOIN
    persons p
ON
    p.CENTER = su.PERSON_CENTER
AND p.ID = su.PERSON_ID

LEFT JOIN
    participations pa
ON
    pa.booking_center = t.BOOKING_CENTER
AND pa.booking_id = t.BOOKING_ID
LEFT JOIN
    persons mem
ON
    mem.center = pa.participant_center
AND mem.id = pa.participant_id
WHERE
    t.bk_starttime !=t.bk_stoptime