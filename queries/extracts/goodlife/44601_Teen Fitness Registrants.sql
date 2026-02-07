SELECT

p.center||'p'||p.id AS teen_id
,p.fullname AS teen_name
,p2.center||'p'||p2.id AS parent_id 
,p2.fullname AS parent_name
,ss.sales_date
,s.start_date
,s.end_date
,bi_decode_field('SUBSCRIPTIONS', 'STATE', s.state) AS "State"
,bi_decode_field('SUBSCRIPTIONS', 'SUB_STATE', s.sub_state) AS "Sub_state"

FROM

subscription_sales ss

JOIN products pr
ON ss.subscription_type_center = pr.center
AND ss.subscription_type_id = pr.id
AND ss.type = 1
AND pr.ptype = 10
AND ss.sales_date >= '2025-01-01'
AND pr.name = 'Teen Fitness Access'

JOIN subscriptions s
ON ss.subscription_center = s.center
AND ss.subscription_id = s.id

JOIN persons p
ON s.owner_center = p.center
AND s.owner_id = p.id


LEFT JOIN relatives r
ON ss.owner_center = r.relativecenter
AND ss.owner_id = r.relativeid
AND r.rtype = 14
AND r.status = 1

LEFT JOIN persons p2
ON r.center = p2.center
AND r.id = p2.id
