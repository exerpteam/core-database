 SELECT
     c.SHORTNAME as center,
     COUNT(DISTINCT p.CURRENT_PERSON_CENTER||'p'||p.CURRENT_PERSON_ID) AS "Unique Visits"
 FROM
     PERSONS p
 JOIN
     CHECKINS ch
 ON
     ch.PERSON_CENTER = p.center
     AND ch.PERSON_ID = p.id
 JOIN
     CENTERS c
 ON
     c.id = ch.CHECKIN_CENTER
 WHERE
     ch.CHECKIN_TIME BETWEEN $$from_date$$ AND $$to_date$$
     AND ch.CHECKIN_CENTER IN ($$scope$$)
 GROUP BY
     c.SHORTNAME
