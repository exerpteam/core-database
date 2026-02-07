WITH
    params AS materialized
    (
        SELECT
            CAST(datetolongC(TO_CHAR(TO_DATE((:fromdate), 'YYYY-MM-DD'), 'YYYY-MM-DD'), c.id) AS BIGINT) AS fromDate,
            CAST(datetolongC(TO_CHAR(TO_DATE((:todate), 'YYYY-MM-DD')+interval '1 day', 'YYYY-MM-DD'), c.id) AS BIGINT) AS toDate,
            c.id
        FROM
            centers c
        WHERE
            c.country = 'NO'
    )
SELECT
    p.center ||'p'|| p.id AS person_id,
    p.external_id,
    p.fullname,
    att.name                                                               AS resource_name,
    TO_CHAR(longtodateC(ch.checkin_time, ch.checkin_center), 'YYYY-MM-DD') AS DATE,
    TO_CHAR(longtodateC(ch.checkin_time, ch.checkin_center), 'HH24:MI:SS') AS checkin_time,
    TO_CHAR(longtodateC(att.start_time, att.center), 'HH24:MI:SS')         AS attend_time,
    CASE
        WHEN ch.checkin_result = 1
        THEN 'Success'
        WHEN ch.checkin_result = 2
        THEN 'Presence registered'
        WHEN ch.checkin_result = 3
        THEN 'Failed'
    END                      AS checkin_status,
    ch.checkin_failed_reason AS checkin_failed_reason
FROM
    persons p
JOIN
    checkins ch
ON
    ch.person_center = p.center
AND ch.person_id = p.id
JOIN
    params par
ON
    par.id = ch.checkin_center
LEFT JOIN
    (
        SELECT
            at.person_center,
            at.person_id,
            at.center,
            at.start_time,
            br.name
        FROM
            attends at
        JOIN
            booking_resources br
        ON
            br.center = at.booking_resource_center
        AND br.id = at.booking_resource_id ) att
ON
    att.person_center = ch.person_center
AND att.person_id = ch.person_id
AND att.center = ch.checkin_center
AND att.start_time >= ch.checkin_time
AND (
        att.start_time <= ch.checkout_time
    OR  ch.checkout_time IS NULL)
AND ch.checkin_result = 1
WHERE
    ch.checkin_time BETWEEN par.fromdate AND par.todate
AND p.persontype != 2
AND ch.checkin_center IN (:scope)
AND (ch.checkin_result = 3 OR (ch.checkin_result IN (1,2) AND att.name IS NOT NULL))