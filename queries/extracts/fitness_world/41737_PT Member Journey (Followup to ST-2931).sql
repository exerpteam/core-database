-- The extract is extracted from Exerp on 2026-02-08
-- https://clublead.atlassian.net/browse/ST-3099
SELECT 
   t1.MemberID AS "Member ID", 
   t1.Sex AS "Sex", 
   t1.Age AS "Age", 
   t1.MemberFirstActive AS "Member First Active", 
   t1.SubscriptionCreationDate AS "Subscription Creation Date", 
   t1.SubscriptionEndDate AS "Subscription End Date", 
   SUM(t1.PT) AS "PT attends"
FROM 
(SELECT 
   p.CENTER||'p'||p.ID AS MemberID, 
   p.SEX AS Sex, 
   floor(months_between(exerpsysdate(), p.BIRTHDATE) / 12) AS Age, 
   to_char(p.FIRST_ACTIVE_START_DATE,'YYYY-MM-dd') AS MemberFirstActive, 
   to_char(s.START_DATE,'YYYY-MM-dd') AS SubscriptionCreationDate, 
   to_char(s.END_DATE,'YYYY-MM-dd') AS SubscriptionEndDate, 
   CASE r.Name
     WHEN 'Personlig træning' THEN 1
     WHEN 'Kostvejledning' THEN 1
     ELSE 0
   END AS PT,
   r.Name
FROM 
   PERSONS p  
JOIN
   SUBSCRIPTIONS s 
ON
   p.CENTER = s.OWNER_CENTER 
   AND p.ID = s.OWNER_ID 
LEFT JOIN
   ATTENDS a
ON
   p.id = a.PERSON_ID 
   AND p.center = a.PERSON_CENTER
LEFT JOIN
   BOOKING_RESOURCES r
ON
   a.BOOKING_RESOURCE_CENTER = r.center 
   AND a.BOOKING_RESOURCE_ID = r.id
   AND r.STATE = 'ACTIVE'
WHERE
   p.center in (:scope)
   AND s.START_DATE >= :startDate 
   AND s.START_DATE <= :endDate
) t1
GROUP BY  
  t1.MemberID, t1.Sex, t1.Age, t1.MemberFirstActive, t1.SubscriptionCreationDate, t1.SubscriptionEndDate
  