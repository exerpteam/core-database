-- The extract is extracted from Exerp on 2026-02-08
--  
SELECT
  per.CENTER || 'p' || per.ID AS member,
  CASE per.persontype
    WHEN 0 THEN 'Private'
    WHEN 1 THEN 'Student'
    WHEN 2 THEN 'Staff'
    WHEN 3 THEN 'Friend'
    WHEN 4 THEN 'Corporate'
    WHEN 5 THEN 'Onemancorporate'
    WHEN 6 THEN 'Family'
    WHEN 7 THEN 'Senior'
    WHEN 8 THEN 'Guest'
    WHEN 9 THEN 'Child'
    WHEN 10 THEN 'External_Staff'
    ELSE 'Unknown'
  END AS "Person Type",
  CASE per.STATUS
    WHEN 0 THEN 'LEAD'
    WHEN 1 THEN 'ACTIVE'
    WHEN 2 THEN 'INACTIVE'
    WHEN 3 THEN 'TEMPORARYINACTIVE'
    WHEN 4 THEN 'TRANSFERRED'
    WHEN 5 THEN 'DUPLICATE'
    WHEN 6 THEN 'PROSPECT'
    WHEN 7 THEN 'DELETED'
    WHEN 8 THEN 'ANONYMIZED'
    WHEN 9 THEN 'CONTACT'
    ELSE 'UNKNOWN'
  END AS STATUS,
  per.FULLNAME,
  pea.txtvalue
FROM
  PERSONS per
JOIN person_ext_attrs pea
  ON per.center = pea.personcenter 
  AND per.id = pea.personid
  AND pea.name = 'CREATION_DATE'
WHERE
  per.FIRSTNAME like '%temp%'
  AND per.LASTNAME like '%temp%'
AND to_date(pea.txtvalue, 'yyyy-mm-dd') >= CURRENT_DATE - INTERVAL '90 day'
AND to_date(pea.txtvalue, 'yyyy-mm-dd') < CURRENT_DATE
AND per.status = 1
