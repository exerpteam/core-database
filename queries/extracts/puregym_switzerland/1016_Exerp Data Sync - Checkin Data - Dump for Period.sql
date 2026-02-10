-- The extract is extracted from Exerp on 2026-02-08
--  
SELECT
     c.ID             AS "VISIT_ID",
     c.CHECKIN_CENTER AS "CHECKIN_CENTER_ID",
     cp.EXTERNAL_ID   AS "EXTERNALID",
     p.CENTER         AS "HOME_CENTER_ID",
     TO_CHAR(longtodateC(c.CHECKIN_TIME, c.CHECKIN_CENTER),'yyyy-MM-dd HH24:MI:SS')         AS "STARTTIME",
 TO_CHAR(longtodateC(c.CHECKOUT_TIME,c.CHECKIN_CENTER),'yyyy-MM-dd HH24:MI:SS')         AS "ENDTIME",
     CASE c.CHECKIN_RESULT
             WHEN 1 THEN  'ACCESS_GRANTED'
             WHEN 2 THEN  'PRESENCE_REGISTERED'
             WHEN 3 THEN  'ACCESS_DENIED'
             ELSE 'UNKNOWN' END AS "CHECKIN_RESULT"
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
     c.CHECKIN_CENTER in (:scope)
     AND c.CHECKIN_TIME >= $$fromdate$$
    AND c.CHECKIN_TIME < $$todate$$ + (86400 * 1000)
   AND c.checked_out = TRUE