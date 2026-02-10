-- The extract is extracted from Exerp on 2026-02-08
-- Members with active & transferred clip cards
SELECT
    c.OWNER_CENTER||'p'||OWNER_id "Member"
FROM
    CLIPCARDS c
JOIN
    CARD_CLIP_USAGES ccu
ON
    ccu.CARD_CENTER = c.CENTER
AND ccu.CARD_ID = c.ID
AND ccu.CARD_SUBID = c.SUBID
WHERE
    --c.OWNER_CENTER = 151
    --and c.OWNER_ID = 178337
    ccu.type = 'TRANSFER_TO'
AND ccu.state = 'ACTIVE'
AND c.CANCELLED = 0
AND c.blocked = 0
AND c.finished = 0
