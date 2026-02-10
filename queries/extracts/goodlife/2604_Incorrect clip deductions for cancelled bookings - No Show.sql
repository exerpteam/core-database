-- The extract is extracted from Exerp on 2026-02-08
-- Looks for member bookings that were cancelled before the 24 hour time configuration limit, but where a bug caused the member to still show as participating, resulting in an incorrect clip being deducted for a No Show
SELECT DISTINCT
    p.center||'p'||p.id AS id,
    p.fullname,
    TO_CHAR(longtodateC(bk.cancelation_time, p.center),'YYYY-MM-DD') cancelation_time,
    TO_CHAR(longtodateC(bk.starttime, p.center),'YYYY-MM-DD')        starttime,
    bk.name                                    booking_name
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
    goodlife.activity ac
ON
    bk.activity = ac.id
JOIN
    goodlife.booking_time_configs bt
ON
    ac.time_config_id = bt.id
AND bt.id IN (1,2)
WHERE
    pa.state = 'CANCELLED'
AND bk.state = 'CANCELLED'
AND pa.cancelation_reason = 'NO_SHOW'
AND bk.cancelation_time < bk.starttime-(1000*60*60*24)
ORDER BY
    p.center||'p'||p.id,
    TO_CHAR(longtodateC(bk.starttime, p.center),'YYYY-MM-DD') DESC