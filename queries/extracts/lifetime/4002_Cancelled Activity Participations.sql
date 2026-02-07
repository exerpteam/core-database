WITH
    params AS
    (
        SELECT
            c.id AS CENTER_ID,
            datetolongc(TO_CHAR(to_date($$start_date$$, 'YYYY-MM-DD HH24:MI:SS'),
            'YYYY-MM-DD HH24:MI:SS'), c.id) AS FROM_DATE,
            datetolongc(TO_CHAR(to_date($$to_date$$, 'YYYY-MM-DD HH24:MI:SS'),
            'YYYY-MM-DD HH24:MI:SS'), c.id) + (24*3600*1000) - 1 AS TO_DATE
        FROM
            centers c
        WHERE
            c.id IN ($$scope$$)
    )
SELECT
    longtodateC(b.starttime,b.center)             AS bookingstarttime,
    longtodateC(pa.cancelation_time,b.center)     AS participation_cancel_time,
    longtodateC(pa.last_modified,b.center)        AS participation_lastmod,
    b.name                                        AS bookingname,
    B.CENTER||'book'||B.ID                        AS BOOKINGID,
    b.state                                       AS BookingState,
    pa.participant_center||'p'||pa.participant_id AS memberid,
	per.external_id AS MMS_ID,
	per.fullname AS MEMBER_FULLNAME,
    pa.state                                      AS participation_state,
    staff.center||'p'||staff.id                   AS staff_who_cancelled,
    staff.fullname                                AS staff_fullname,
    pa.cancelation_reason,
    CASE
        WHEN a.activity_type = 2
        THEN 'Class'
        WHEN a.activity_type = 3
        THEN 'Resource booking'
        WHEN a.activity_type = 4
        THEN 'Staff booking'
        WHEN a.activity_type = 9
        THEN 'Course'
        ELSE NULL
    END AS activitytype
    --,longtodateC(b.stoptime,b.center)          AS bookingstoptime,
    --PA.*
FROM
    participations pa
JOIN
    bookings b
ON
    pa.booking_center = b.center
AND pa.booking_id = b.id
join persons per on pa.participant_center = per.center and pa.participant_id = per.id
JOIN
    activity a
ON
    a.id = b.activity
JOIN
    persons staff
ON
    pa.cancelation_by_center = staff.center
AND pa.cancelation_by_id = staff.id
JOIN
    centers c
ON
    c.id = b.center
JOIN
    params
ON
    params.CENTER_ID = c.id
WHERE
    --a.activity_type = 9
    --AND
    pa.state ='CANCELLED'
AND pa.cancelation_time BETWEEN params.FROM_DATE AND params.TO_DATE
    --order by START_DATETIME,TRAINER,BOOKING_NAME,MEMBER_FULLNAME
ORDER BY
    bookingstarttime ASC,
    participation_cancel_time ASC,staff_fullname ASC
