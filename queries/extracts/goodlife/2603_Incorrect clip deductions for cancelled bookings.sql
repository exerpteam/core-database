-- The extract is extracted from Exerp on 2026-02-08
-- Looks for member bookings that were cancelled, but where a bug caused the member to still show as participating, resulting in an incorrect clip being deducted when the member signed in for another booking that day.
SELECT DISTINCT
    p.center||'p'||p.id                        AS memberid,
    p.fullname                                    membername,
    pr.name                                       clipcard,
    TO_CHAR(longtodateC(pu.use_time, pu.person_center),'YYYY-MM-DD') AS clip_use_time,
    bk.name                                       booking_name,
    bk.cancellation_reason
FROM
    goodlife.participations pa
JOIN
    bookings bk
ON
    bk.center = pa.booking_center
AND bk.id = pa.booking_id
JOIN
    goodlife.persons p
ON
    pa.participant_center = p.center
AND pa.participant_id = p.id
JOIN
    goodlife.clipcards cc
ON
    cc.owner_center = p.center
AND p.id = cc.owner_id
JOIN
    goodlife.privilege_usages pu
ON
    pu.privilege_type = 'BOOKING'
AND pu.state = 'USED'
AND pu.target_service = 'Participation'
AND PU.person_center = P.center
AND pu.person_id = p.id
AND pu.source_center = cc.center
AND pu.source_id = cc.id
AND pu.source_subid= cc.subid
AND pu.target_center = pa.center
AND pu.target_id = pa.id
JOIN
    goodlife.privilege_grants pg
ON
    pu.grant_id = pg.id
AND pg.GRANTER_SERVICE IN ('GlobalCard',
                           'LocalCard')
LEFT JOIN
    goodlife.products pr
ON
    pr.center = cc.center
AND pr.id = cc.id
WHERE
    pa.state != 'CANCELLED'
AND bk.state = 'CANCELLED'
ORDER BY
    p.center||'p'||p.id,
    pr.name,
    TO_CHAR(longtodateC(pu.use_time, pu.person_center),'YYYY-MM-DD') DESC