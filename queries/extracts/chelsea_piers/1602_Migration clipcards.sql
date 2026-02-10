-- The extract is extracted from Exerp on 2026-02-08
--  
SELECT
    c.center,
    c.id,
    c.subid,
	c.owner_center || 'p' || c.owner_id as PersonId,
    pr.name,
    pr.globalid,
    c.clips_initial,
    c.clips_left,
    c.finished,
    c.cancelled,
    c.blocked,	
	c.cc_comment,
    SUM(
        CASE
            WHEN ccu.employee_center = 100
            AND ccu.employee_id = 1
            AND ccu.description = 'Data migration'
            THEN ccu.clips
            ELSE 0
        END) MIGRATED_USAGE,
    SUM(
        CASE
            WHEN ccu.description NOT IN ('transfer',
                                         'Data migration')
            AND ccu.state NOT IN ('CANCELLED')
            THEN ccu.clips
            ELSE 0
        END) EXERP_USAGE,
    SUM(
        CASE
            WHEN ccu.description = 'transfer'
            AND ccu.state NOT IN ('CANCELLED')
            THEN ccu.clips
            ELSE 0
        END) TRANSFER
FROM
    chelseapiers.clipcards c
JOIN
    chelseapiers.products pr
ON
    c.center = pr.center
AND c.id = pr.id
LEFT JOIN
    chelseapiers.card_clip_usages ccu
ON
    c.center = ccu.card_center
AND c.id = ccu.card_id
AND c.subid = ccu.card_subid
WHERE
    c.cc_comment IS NOT NULL
GROUP BY
    c.center,
    c.id,
    c.subid,
    pr.name,
    pr.globalid,
    c.clips_initial,
    c.clips_left,
c.finished,
    c.cancelled,
    c.blocked,	
	c.cc_comment