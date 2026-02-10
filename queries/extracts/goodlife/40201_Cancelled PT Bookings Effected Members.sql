-- The extract is extracted from Exerp on 2026-02-08
-- Cancelled PT Bookings Effected Members
SELECT
   -- su.person_center||'p'||su.person_id           AS "Staff Person",
    pa.participant_center||'p'||pa.participant_id AS "Person ID",
    pea.txtvalue as "Email",
    TO_CHAR(longtodatec(b.starttime,b.center), 'yyyy-mm-dd')
FROM
    bookings b
left JOIN
    goodlife.persons per
    ON
    per.center = b.owner_center
AND per.id = b.owner_id
left JOIN
    goodlife.person_ext_attrs pea
ON
    pea.personcenter = per.center
AND pea.personid = per.id
and pea.name = '_eClub_Email'
JOIN
    goodlife.activity a
ON
    b.activity = a.id
JOIN
    goodlife.activity_group ag
ON
    ag.id = a.activity_group_id
AND ag.name IN ('Team Training',
                'Personal Training',
                'PT Service',
                'PT Complimentary Session')
JOIN
    centers c
ON
    c.id = b.center
JOIN
    goodlife.staff_usage su
ON
    su.booking_center = b.center
AND su.booking_id = b.id
JOIN
    goodlife.participations pa
ON
    pa.booking_center = b.center
AND pa.booking_id = b.id
WHERE
    b.starttime BETWEEN datetolongTZ(TO_CHAR(to_date('2022-01-05','yyyy-mm-dd'),
    'YYYY-MM-DD HH24:MI:SS' ),c.time_zone)::BIGINT AND datetolongTZ(TO_CHAR(to_date('2022-01-06',
    'yyyy-mm-dd'),'YYYY-MM-DD HH24:MI:SS' ),c.time_zone)-1::BIGINT
AND b.cancelation_by_center = 990
AND b.cancelation_by_id = 69820
AND b.state = 'CANCELLED'
AND longtodatec(b.cancelation_time,b.center) >= '2022-01-04'
ORDER BY
    1 DESC