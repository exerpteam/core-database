-- The extract is extracted from Exerp on 2026-02-08
-- https://clublead.atlassian.net/browse/ST-4934
 SELECT
     c.SHORTNAME "Home Club",
     p.center||'p'||p.id "Member ID",
     cp.EXTERNAL_ID as "External ID",
     cp.FIRSTNAME "First Name",
     cp.LASTNAME  "Last Name",
     p.SEX AS "SEX"
 FROM
     PERSONS p
 JOIN
     CENTERS c
 ON
     c.ID = p.CENTER
     AND c.COUNTRY = 'GB'
 JOIN
     (SELECT PERSON_CENTER, PERSON_ID
      FROM
         CHECKINS ch
      WHERE
         ch.CHECKIN_TIME >=  :Visit_From_Date
         AND ch.CHECKIN_TIME < :Visit_To_Date+24*3600*1000
         AND ch.CHECKIN_CENTER = :Club
      GROUP BY PERSON_CENTER, PERSON_ID
      HAVING COUNT(*) > 0
      ) visit
 ON
     visit.PERSON_CENTER = p.CENTER
     AND visit.PERSON_ID = p.ID
 JOIN
     PERSONS cp
 ON
     cp.CENTER = p.CURRENT_PERSON_CENTER
     AND cp.ID = p.CURRENT_PERSON_ID
 WHERE
     --p.PERSONTYPE <> 2  --exclude staff --asked to not restrict staff on this by Jonny 15/11/21 via: #INC-256358
     ((current_date - p.birthdate)/365) > 18  -- Age over 18
     AND ((upper(p.SEX) = upper(TRIM(:Gender))) OR (TRIM(:Gender)='ALL'))
     AND p.center in (:Home_Club)
