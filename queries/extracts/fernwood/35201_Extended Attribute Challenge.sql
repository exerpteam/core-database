SELECT 
  p.center || 'p' || p.id AS "Person ID",
  c.shortname AS "Club Name",
  p.firstname || ' ' || p.lastname AS "Full Name",
  MAX(CASE WHEN pea.name = 'Challenge' THEN pea.txtvalue END) AS "Challenge Class"
FROM 
  fernwood.persons p
LEFT JOIN 
  fernwood.person_ext_attrs pea
  ON pea.personcenter = p.center
  AND pea.personid = p.id
LEFT JOIN 
  fernwood.centers c
  ON c.id = p.center
GROUP BY 
  p.center, p.id, p.firstname, p.lastname, c.shortname
HAVING 
  MAX(CASE WHEN pea.name = 'Challenge' THEN pea.txtvalue END) = 'Y'
ORDER BY 
  p.center, p.lastname;

