WITH notoverdue AS

(

SELECT

c.owner_center
,c.owner_id
,c.center
,c.id
,c.subid
,p.name
,c.valid_from
,c.clips_left
,c.clips_initial


FROM

clipcards c

JOIN products p
ON c.center = p.center
AND c.id = p.id
AND c.center||'cc'||c.id||'id'||c.subid IN (:CLIPID)
AND c.overdue_since IS NULL
    )
    
SELECT 

a.owner_center||'p'||a.owner_id AS "Person ID"
,a.center||'cc'||a.id||'id'||a.subid AS "Clip Card ID"
,a.name AS "Clip Card Product Name"
,LONGTODATEC(a.valid_from,a.center) AS "Valid From Date"
,a.clips_initial AS "Initial Amount of Clips"
,a.clips_left AS "Clips Remaining"
,SUM(cc.clips) AS "Total Clips Used"
,(a.clips_initial + SUM(cc.clips + a.clips_left)) AS "Clips to be removed"

FROM

card_clip_usages cc

JOIN notoverdue a
ON cc.card_center = a.center
AND cc.card_id = a.id
AND cc.card_subid = a.subid
AND cc.state = 'ACTIVE'


GROUP BY

a.owner_center||'p'||a.owner_id
,a.center||'cc'||a.id||'id'||a.subid
,a.name
,a.valid_from
,a.center
,a.clips_left
,a.clips_initial