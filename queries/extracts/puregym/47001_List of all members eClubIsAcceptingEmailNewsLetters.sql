-- The extract is extracted from Exerp on 2026-02-08
-- https://clublead.atlassian.net/browse/ST-4143
SELECT 
   p.CENTER||'p'||p.ID AS "Member ID",
   DECODE(pea_newsletter.TXTVALUE,'true','Yes','false','No') AS "Newsletter Accepted",
   TO_CHAR(longtodateC(pea_newsletter.LAST_EDIT_TIME,p.CENTER),'YYYY-MM-DD') AS "Date of Acceptance"
FROM 
  Persons p
LEFT JOIN
  PERSON_EXT_ATTRS pea_newsletter
ON
  p.CENTER = pea_newsletter.PERSONCENTER
  AND p.ID = pea_newsletter.PERSONID
  AND pea_newsletter.name = 'eClubIsAcceptingEmailNewsLetters'
WHERE
 pea_newsletter.TXTVALUE = 'true'