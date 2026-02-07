SELECT
    b.name                              AS ACTIVITY,
    longtodateC(b.starttime,b.center)   AS start_time,
    pu.person_center||'p'||pu.person_id AS memberid,
    mem.fullname                        AS MEMBER_FULLNAME,
    mem.external_id                     AS LTF_ID,
    per.fullname                        AS TRAINER
    --,b.*
FROM
    lifetime.privilege_usages pu
JOIN
    privilege_grants pg
ON
    pg.id = pu.grant_id
JOIN
    lifetime.participations p
ON
    p.center = pu.target_center
AND p.id = pu.target_id
JOIN
    PERSONS mem
ON
    mem.center = p.participant_center
AND mem.id = p.participant_id
JOIN
    bookings b
ON
    b.center = p.booking_center
AND b.id = p.booking_id
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
WHERE
    pg.privilege_set = 403
AND pu.state = 'USED'
ORDER BY
    TRAINER ASC