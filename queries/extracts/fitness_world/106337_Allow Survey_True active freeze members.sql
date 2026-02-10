-- The extract is extracted from Exerp on 2026-02-08
--  
select p.CENTER ||'p'|| p.ID,
pea1.NAME,
pea1.TXTVALUE
from persons p
join person_ext_attrs pea1
ON pea1.personcenter = p.CENTER
JOIN SUBSCRIPTIONS s
ON p.CENTER = s.OWNER_CENTER
AND p.ID = s.OWNER_ID
AND pea1.personid = p.ID
AND pea1.NAME = 'AllowSurvey'
AND pea1.txtvalue = 'true'
WHERE
s.STATE in (2,4)
AND p.CENTER in (:scope)