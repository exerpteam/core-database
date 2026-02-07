SELECT

c.owner_center||'p'||c.owner_id AS personid
,p.name AS product
,c.*

FROM

clipcards c

JOIN products p
ON c.center = p.center
AND c.id = p.id

WHERE 

c.center IN (:scope)