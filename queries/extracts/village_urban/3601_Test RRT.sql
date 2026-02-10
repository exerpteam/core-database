-- The extract is extracted from Exerp on 2026-02-08
--  
SELECT
    p.center,p.id,p.status
FROM
    persons p
LEFT JOIN
    person_ext_attrs pea
ON
    pea.personcenter = p.center
AND pea.personid = p.id
AND pea.name = '_eClub_WellnessCloudUserPermanentToken'
WHERE
    p.STATUS IN (1,3)
AND p.persontype != 2
AND p.center IN (:Scope)
AND pea.txtvalue IS NULL

UNION

SELECT DISTINCT
    p.center,p.id, p.status
FROM
    persons p
JOIN
    clipcards c
ON
    c.owner_center = p.center
AND c.owner_id = p.id
LEFT JOIN
    person_ext_attrs pea
ON
    pea.personcenter = p.center
AND pea.personid = p.id
AND pea.name = '_eClub_WellnessCloudUserPermanentToken'
WHERE
    c.clips_left > 0
AND c.finished = 0
AND c.cancelled = 0
AND c.blocked = 0
AND p.status IN (1,3)
AND p.persontype != 2
AND p.center IN (:Scope)
AND pea.txtvalue IS NULL

UNION

SELECT DISTINCT
    p.center,p.id,p.status
FROM
    persons p
JOIN
    subscriptions s
ON
    p.center = s.owner_center
AND p.id = s.owner_id
LEFT JOIN
    person_ext_attrs pea
ON
    pea.personcenter = p.center
AND pea.personid = p.id
AND pea.name = '_eClub_WellnessCloudUserPermanentToken'
WHERE
    p.center IN (:Scope)
AND p.persontype != 2
AND pea.txtvalue IS NULL