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
    TO_CHAR(longtodatec(b.STARTTIME,b.center), 'YYYY-MM-DD HH24:MI') AS START_DATETIME,
    b.NAME                                                       AS BOOKING_NAME,
    per.fullname                                                 AS TRAINER,
    a.name                                                       AS ACTIVITY,
    ag.NAME                                                      AS ACTIVITY_GROUP,
    mem.center || 'p' || mem.id                                  AS MEMBER_ID,
    mem.external_id                                              AS MMS_ID,
    mem.fullname                                                 AS MEMBER_FULLNAME,
    part.state                                                   AS PARTICIPATION_STATE,
    part.cancelation_reason                                      AS CANCELLATION_REASON,
    CASE
        WHEN part.state = 'BOOKED'
        THEN 'N/A'
        WHEN part.state = 'PARTICIPATION'
        THEN 'Show-up'
        WHEN part.state = 'CANCELLED'
        AND part.cancelation_reason = 'NO_SHOW'
        THEN 'No-Show'
        WHEN part.state = 'CANCELLED'
        AND part.cancelation_reason = 'BOOKING'
        THEN 'Booking cancelled'
        WHEN part.state = 'CANCELLED'
        AND part.cancelation_reason = 'NO_PRIVILEGE'
        THEN 'Cancelled (No privilege)'
        WHEN part.state = 'CANCELLED'
        AND part.cancelation_reason IN ('USER',
                                        'CENTER')
        THEN 'Cancelled by staff or user'
        ELSE 'Other'
    END AS SHOWUP_STATUS
FROM
    bookings b
JOIN
    params
ON
    b.center = center_id
JOIN
    ACTIVITY a
ON
    a.id = b.ACTIVITY
JOIN
    ACTIVITY_GROUP ag
ON
    ag.id = a.ACTIVITY_GROUP_ID
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
    PARTICIPATIONS part
ON
    b.center = part.BOOKING_CENTER
AND b.id = part.BOOKING_ID
JOIN
    PERSONS mem
ON
    mem.center = part.participant_center
AND mem.id = part.participant_id
WHERE
    b.state = 'ACTIVE'
AND b.STARTTIME BETWEEN params.FROM_DATE AND params.TO_DATE
ORDER BY
    START_DATETIME,
    TRAINER,
    BOOKING_NAME,
    MEMBER_FULLNAME