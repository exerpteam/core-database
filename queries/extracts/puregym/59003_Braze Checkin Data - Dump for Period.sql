-- The extract is extracted from Exerp on 2026-02-08
--  
SELECT 
    c.ID             AS "VISIT_ID",
    c.CHECKIN_CENTER AS "CHECKIN_CENTER_ID",
    cp.EXTERNAL_ID   AS "EXTERNALID",
    p.CENTER         AS "HOME_CENTER_ID",
    TO_CHAR(longtodateC(c.CHECKIN_TIME, c.CHECKIN_CENTER),'yyyy-MM-dd HH24:MI:SS')         AS "STARTTIME",
TO_CHAR(longtodateC(c.CHECKOUT_TIME,c.CHECKIN_CENTER),'yyyy-MM-dd HH24:MI:SS')         AS "ENDTIME",
    DECODE(c.CHECKIN_RESULT, 
           1, 'ACCESS_GRANTED' , 
           2, 'PRESENCE_REGISTERED', 
           3, 'ACCESS_DENIED',
           'UNKNOWN') AS "CHECKIN_RESULT"
FROM
    CHECKINS c
JOIN
    PERSONS p
ON
    p.CENTER = c.PERSON_CENTER
    AND p.id = c.PERSON_ID
JOIN
    PERSONS cp
ON
    cp.CENTER = p.CURRENT_PERSON_CENTER
    AND cp.id = p.CURRENT_PERSON_ID
WHERE
    c.CHECKIN_CENTER in ($$scope$$)
    AND c.CHECKIN_TIME >= $$fromdate$$
    AND c.CHECKOUT_TIME is not null 
	