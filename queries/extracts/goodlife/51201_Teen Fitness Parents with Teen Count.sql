WITH active_teens AS
(
SELECT DISTINCT
    s.owner_center,
    s.owner_id
FROM
    products pr
JOIN
    subscriptions s
ON
    s.subscriptiontype_center = pr.center
AND s.subscriptiontype_id = pr.id
WHERE
    pr.globalid = 'TEEN_FITNESS'
AND s.start_date <= :subscription_from_date
AND (s.end_date IS NULL OR s.end_date >= :subscription_until_date)
AND NOT (s.start_date > s.end_date)
),
parent_counts as
(
select 
   r.center, r.id, count(*) as number_of_teens_active
from 
  active_teens t
JOIN
  relatives r
ON
  r.relativecenter = t.owner_center   
  AND r.relativeid = t.owner_id
  AND r.status < 2 
  AND r.rtype = 14
GROUP BY 
  r.center,
  r.id
)
select 
  c.id       AS "Club ID",
  c.name       AS "Club Name",
  z.province AS "Member Province",
  cp.firstname  AS  "Parent First Name",
  cp.nickname  AS  "Parent Preferred Name",
  cp.lastname  AS  "Parent Last Name",
  cp.external_id  AS  "Parent External ID",
  number_of_teens_active AS "Teen Count"
from 
  parent_counts parent
JOIN
  persons p
ON 
  p.center = parent.center
  AND p.id = parent.id    
JOIN
  persons cp
ON
  cp.center = p.current_person_center
  AND cp.id = p.current_person_id    
JOIN
  centers c
ON 
  cp.center = c.id  
LEFT JOIN
    ZIPCODES z
ON
    z.COUNTRY = cp.COUNTRY
AND z.ZIPCODE = cp.ZIPCODE
AND z.CITY = cp.CITY 