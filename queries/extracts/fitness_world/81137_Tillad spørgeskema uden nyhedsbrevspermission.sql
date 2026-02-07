-- This is the version from 2026-02-05
--  
select p.CENTER ||'p'|| p.ID,
pea1.NAME,
pea1.TXTVALUE,
pea2.NAME,
pea2.TXTVALUE
from persons p
join person_ext_attrs pea1
ON pea1.personcenter = p.CENTER
AND pea1.personid = p.ID
AND pea1.NAME = 'AllowSurvey'
AND pea1.txtvalue = 'true'
join person_ext_attrs pea2
ON pea2.personcenter = p.CENTER
AND pea2.personid = p.ID
AND pea2.NAME = 'eClubIsAcceptingEmailNewsLetters'
AND pea2.TXTVALUE = 'false'
WHERE
p.CENTER in (:scope)
