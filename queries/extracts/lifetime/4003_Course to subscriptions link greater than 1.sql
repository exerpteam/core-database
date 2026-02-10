-- The extract is extracted from Exerp on 2026-02-08
--  
SELECT
    COUNT(*)                                         AS number_of_courses_rosteredto,
    rp.subscription_center||'ss'||rp.subscription_id AS subscriptionid,
    rp.participant_center||'p'||rp.participant_id    AS memberid,
    p.external_id
FROM
    recurring_participations rp
JOIN
    persons p
ON
    rp.participant_center = p.center
AND rp.participant_id = p.id
WHERE
    rp.subscription_center IS NOT NULL
AND rp.end_time IS NULL
AND rp.state = 'ACTIVE'
GROUP BY
    subscriptionid,
    memberid,
    p.external_id
HAVING
    COUNT (*) >1