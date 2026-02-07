WITH PARAMS AS (
  /*+ materialize */
  select datetolong('2019-08-01 00:00') as august1
),

overused_clipcards AS (

SELECT
    c.owner_center,
    c.owner_id,
    c.center,
    c.id,
    c.subid,
    c.clips_left - SUM(CU.CLIPS) - c.clips_initial as OverUsed
FROM 
    PARAMS,
    CLIPCARDS c
JOIN
    card_clip_usages cu
ON
    cu.card_center = c.center 
    AND cu.card_id = c.id 
    AND cu.card_subid = c.subid 
    AND cu.state = 'ACTIVE'
WHERE 
    c.cancelled = 0 
    AND c.blocked = 0 
    AND c.center in (:centers)
GROUP BY
    c.center, c.id, c.subid, c.owner_center, c.owner_id, c.clips_initial, c.clips_left, params.august1
HAVING  
    c.clips_left - SUM(CU.CLIPS) >  c.clips_initial
    and max(cu.time) > params.august1
)
SELECT
    p.center||'p'||p.id AS "PersonID",
    SUM(cc.clips_left)  AS "Total_Clips_Available",
    MIN(oc.OverUsed)    AS "OverUsed"     
FROM
    overused_clipcards  oc
JOIN
    PERSONS p
ON
    oc.owner_center = p.center
	AND oc.owner_id = p.id
JOIN
    clipcards cc
ON
    p.center = cc.owner_center
	AND p.id = cc.owner_id
WHERE
    cc.cancelled = 0
    AND cc.blocked = 0 
    AND cc.finished = 0
    AND cc.clips_left > 0
    AND cc.center = oc.center
	AND cc.id = oc.id
GROUP BY
    p.center, p.id
   