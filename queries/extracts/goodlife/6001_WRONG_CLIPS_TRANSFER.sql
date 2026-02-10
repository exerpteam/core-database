-- The extract is extracted from Exerp on 2026-02-08
-- ES-1253
SELECT
        cc.owner_center || 'p' || cc.owner_id AS "New Owner",
        cc.clips_left,
        cc.clips_initial,
        ccu.description,
        ccu.state,
        ccu.clips AS "Clips Transferred"
FROM goodlife.clipcards cc
JOIN goodlife.card_clip_usages ccu 
        ON cc.center = ccu.card_center
        AND cc.id = ccu.card_id
        AND cc.subid = ccu.card_subid
        AND ccu.type = 'TRANSFER_TO'
