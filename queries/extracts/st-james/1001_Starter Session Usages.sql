-- The extract is extracted from Exerp on 2026-02-08
-- https://clublead.atlassian.net/browse/EC-9697
WITH
    params AS
    (
        SELECT
            name AS center,
            id   AS CENTER_ID,
            CAST(datetolongTZ(TO_CHAR(to_date($$DateFrom$$,'yyyy-mm-dd'),'YYYY-MM-DD HH24:MI:SS' ), time_zone) AS BIGINT) AS from_date,
            CAST(datetolongTZ(TO_CHAR(to_date($$DateTo$$,'yyyy-mm-dd'),'YYYY-MM-DD HH24:MI:SS' ), time_zone) AS BIGINT) + (24*60*60*1000) AS to_date
        FROM
            centers 
        WHERE
            id IN ($$Scope$$)
    )
SELECT
    pr.name PT_type, 
    cc.owner_center||'p'||cc.owner_id AS Member_ID,
    TO_CHAR(longtodatec(ccu.time, ccu.card_center),'MM/DD/YYYY') AS Usage_Time,
    ccu.type,
    ccu.state,
    ccu.clips,
    ccu.description
FROM
    clipcards cc
JOIN
    params
ON
    cc.center = params.center_id
JOIN
    products pr
ON
    cc.center = pr.center
AND cc.id = pr.id
JOIN
    product_and_product_group_link l
ON
    pr.center = l.product_center
AND pr.id = l.product_id
JOIN
    product_group pg
ON
    pg.id = l.product_group_id
JOIN
    card_clip_usages ccu
ON
    ccu.card_center = cc.center
    AND ccu.card_id = cc.id        
    AND ccu.card_subid = cc.subid
    AND ccu.time >= params.from_date 
    AND ccu.time < params.to_date    
WHERE
    pg.id = 202 -- 'Starter Sessions'