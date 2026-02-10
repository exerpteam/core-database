-- The extract is extracted from Exerp on 2026-02-08
-- 
SELECT 
  p.center || 'p' || p.id AS "Person ID",
  c.shortname AS "Club Name",
  p.firstname || ' ' || p.lastname AS "Full Name",
  MAX(CASE WHEN pea.name = 'AstonRXSubscribed' THEN pea.txtvalue END) AS "AstonRX - Subscribed",
  MAX(CASE WHEN pea.name = 'AstonRXSubscribedDT' THEN pea.txtvalue END) AS "AstonRX - Subscribed DT"
FROM 
  persons p
LEFT JOIN 
  person_ext_attrs pea
  ON pea.personcenter = p.center
  AND pea.personid = p.id
LEFT JOIN 
  centers c
  ON c.id = p.center
GROUP BY 
  p.center, p.id, p.firstname, p.lastname, c.shortname
HAVING 
  MAX(CASE WHEN pea.name = 'AstonRXSubscribed' THEN pea.txtvalue END) = 'yes'
ORDER BY 
  p.center, p.lastname;
