-- The extract is extracted from Exerp on 2026-02-08
-- https://clublead.atlassian.net/browse/EC-3441
WITH params AS materialized
(
   SELECT
        cast(datetolongTZ(TO_CHAR(to_date(:fromdate,'yyyy-mm-dd'),'YYYY-MM-DD HH24:MI:SS' ),c.time_zone)as BIGINT) AS fromdate,
        cast(datetolongTZ(TO_CHAR(to_date(:todate,'yyyy-mm-dd'),'YYYY-MM-DD HH24:MI:SS' ),c.time_zone)+ (24*3600*1000) -1 as BIGINT) AS todate,
        c.id    AS centerid,
        c.name  AS center
   FROM 
        centers c
    WHERE
        c.id IN (:Scope)     
),

clips_used AS
(
SELECT
    cc.owner_center, cc.owner_id, params.center, params.centerid, -sum(ccu.clips) as used_clips
FROM
    clipcards cc
JOIN
    products pc
ON
    cc.center = pc.center
    AND cc.id = pc.id   
JOIN
    params
ON
    params.centerid = cc.center                        
LEFT JOIN 
    CARD_CLIP_USAGES ccu
ON
    cc.center = ccu.card_center
    AND cc.id = ccu.card_id
    AND cc.subid = ccu.card_subid 
    AND ccu.state = 'ACTIVE'    
    AND ccu.time between params.fromdate AND params.todate
    --AND ccu.type = 'PRIVILEGE'
    
WHERE 
  --  pc.globalid = 'COMP_SESSION' 
    pc.globalid = 'COMPLIMENTARY_GUEST_PASS'    
    

GROUP BY cc.owner_center,cc.owner_id, params.center, params.centerid      
)
,
balance AS (
SELECT 
  c.owner_center,
  c.owner_id, 
  SUM(c.clips_left)   AS "CurrentBalance"
FROM 
  clipcards c
JOIN
    products pc
ON
    c.center = pc.center
    AND c.id = pc.id                   
JOIN
    persons p
ON
    p.center = c.owner_center
    AND p.id = c.owner_id 
WHERE 
--    pc.globalid = 'COMP_SESSION' 
  pc.globalid = 'COMPLIMENTARY_GUEST_PASS'    
    AND c.finished = false
GROUP BY 
    c.owner_center, c.owner_id 
)
SELECT 
   c.centerid                           AS "Club ID", 
   c.center                             AS "Club Name", 
   c.owner_center||'p'||c.owner_id      AS "Person ID",
   p.firstname                          AS "Person First Name",
   p.lastname                           AS "Person Last Name",
   COALESCE(c.used_clips,0)             AS "Guest Passes Used",
   COALESCE(b."CurrentBalance",0)       AS "Current Balance"
FROM 
   clips_used c
JOIN
   persons p
ON 
   c.owner_center = p.center   
   AND c.owner_id = p.id
LEFT JOIN
   balance b
ON
   c.owner_center = b.owner_center
   AND c.owner_id = b.owner_id