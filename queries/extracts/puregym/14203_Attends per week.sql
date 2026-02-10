-- The extract is extracted from Exerp on 2026-02-08
--  
SELECT
 c.SHORTNAME as center,
    GREATEST(TRUNC(longtodate(ch.CHECKIN_TIME)-4,'WW')+4,longtodatetz($$from_date$$,'Europe/London')) AS FROM_DATE,
    least(TRUNC(longtodate(ch.CHECKIN_TIME)-4,'WW')+4 +7,longtodatetz($$to_date$$,'Europe/London')) AS TO_DATE,
    COUNT(DISTINCT p.CURRENT_PERSON_CENTER||'p'||p.CURRENT_PERSON_ID)                              AS "Unique Visits"
FROM
    PUREGYM.PERSONS p
JOIN
    PUREGYM.CHECKINS ch
ON
    ch.PERSON_CENTER = p.center
    AND ch.PERSON_ID = p.id
JOIN
    PUREGYM.CENTERS c
ON
    c.id = ch.CHECKIN_CENTER
WHERE
    ch.CHECKIN_CENTER IN($$scope$$)
    AND ch.CHECKIN_TIME BETWEEN $$from_date$$ AND $$to_date$$
GROUP BY
c.SHORTNAME,
    TRUNC(longtodate(ch.CHECKIN_TIME)-4,'WW')+4 ,
    TRUNC(longtodate(ch.CHECKIN_TIME)-4,'WW')+4 +7
ORDER BY
    1