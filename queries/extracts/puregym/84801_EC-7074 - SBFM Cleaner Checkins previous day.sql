-- The extract is extracted from Exerp on 2026-02-08
--  
WITH
    PARAMS AS MATERIALIZED
    (
        SELECT
            CAST(dateToLongC(TO_CHAR(TO_DATE(getCenterTime(c.id), 'YYYY-MM-DD') - interval '1 Day', 'YYYY-MM-DD'),c.id ) AS bigint) 		AS fromDate,
            CAST(dateToLongC(TO_CHAR(TO_DATE(getCenterTime(c.id), 'YYYY-MM-DD'),
            'YYYY-MM-DD'),c.id ) AS bigint)-1 				AS toDate,
            c.id                                            AS centerID,
            c.name                                          AS Centername
        FROM
            centers c
    )
SELECT
    p.fullname                                                               AS Fullname,
    c.name                                                                AS Home_center,
    pea.txtvalue                                                          AS Email_address,
    p.center ||'p'|| p.id                                                              AS Person_id,
    params.Centername                                                             AS Checkin_center,
    TO_CHAR(longtodateC(ch.checkin_time, ch.checkin_center), 'dd/MM/YYYY HH12:MI:SS AM') AS
    Checkin_start,
    TO_CHAR(longtodateC(ch.checkout_time, ch.checkin_center), 'dd/MM/YYYY HH12:MI:SS AM') AS
    Checkout_time
FROM
    persons p
JOIN
    centers c
ON
    c.id = p.center
JOIN
    person_ext_attrs pea
ON
    pea.personcenter = p.center
AND pea.personid = p.id
AND pea.name = '_eClub_Email'
AND pea.txtvalue = 'puregym@sb-fm.co.uk'
JOIN
    checkins ch
ON
    ch.person_center = p.center
AND ch.person_id = p.id
AND ch.checkin_result != 3
JOIN
    params
ON
    params.centerID = ch.checkin_center
WHERE
    p.persontype = 2
AND ch.checkin_time BETWEEN params.fromDate AND params.toDate
AND ch.checkin_center IN (:scope)
ORDER BY
    p.fullname,
    ch.checkin_center,
    ch.checkin_time,
    ch.checkout_time