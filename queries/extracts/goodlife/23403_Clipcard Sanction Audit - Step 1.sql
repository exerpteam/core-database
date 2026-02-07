SELECT

c.owner_center||'p'||c.owner_id AS "Person ID"
,c.center||'cc'||c.id||'id'||c.subid AS "Clip Card ID"
,p.name AS "Clip Card Product Name"
,LONGTODATEC(c.valid_from,c.center) AS "Valid From Date"
,LONGTODATEC(cc.time,c.center) AS "Sanction Date"

FROM

card_clip_usages cc

JOIN clipcards c
ON cc.card_center = c.center
AND cc.card_id = c.id
AND cc.card_subid = c.subid
AND c.overdue_since < cc.time
AND cc.time > CAST((:Date - to_date('1-1-1970','MM-DD-YYYY')) AS BIGINT)*24*3600*1000 
--AND cc.time > CAST((CURRENT_DATE - 1 - to_date('1-1-1970','MM-DD-YYYY')) AS BIGINT)*24*3600*1000 
AND cc.type = 'SANCTION'
AND cc.state = 'ACTIVE'

JOIN products p
ON c.center = p.center
AND c.id = p.id

ORDER BY

c.owner_center||'p'||c.owner_id
,c.center||'cc'||c.id||'id'||c.subid
,c.valid_from
