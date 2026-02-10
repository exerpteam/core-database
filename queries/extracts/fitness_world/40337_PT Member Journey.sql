-- The extract is extracted from Exerp on 2026-02-08
-- https://clublead.atlassian.net/browse/ST-2931
SELECT p.CENTER||'p'||p.ID AS "MemberID", p.SEX AS "Sex", floor(months_between(exerpsysdate(), p.BIRTHDATE) / 12) AS "Age", c.NAME AS "Club Name" , to_char(p.FIRST_ACTIVE_START_DATE,'YYYY-MM-dd') AS "Member First Active", count(*) AS "PT Attends"
FROM 
  BOOKING_RESOURCES r
JOIN
  ATTENDS a
ON
  a.BOOKING_RESOURCE_CENTER = r.center AND a.BOOKING_RESOURCE_ID = r.id
JOIN
  PERSONS p  
ON
  p.id = a.PERSON_ID AND p.center = a.PERSON_CENTER
JOIN
  CENTERS c
ON
  p.center = c.id
WHERE 
 r.Name in ('Personlig træning','Kostvejledning')
 AND r.STATE = 'ACTIVE'
 AND a.START_TIME >= :DateFrom AND a.START_TIME <= :DateTo
 AND c.id in (:Scope)

GROUP BY  p.CENTER||'p'||p.ID, p.Sex, p.BIRTHDATE, c.NAME,  p.FIRST_ACTIVE_START_DATE
