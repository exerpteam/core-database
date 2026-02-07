 WITH
   params AS materialized
     (
         SELECT
             id   AS  center,
			CAST(datetolongC(to_char(date_trunc('day',to_timestamp(getcentertime(ID), 'YYYY-MM-DD HH24:MI:SS')-interval '3' day),'YYYY-MM-DD HH24:MI'), ID) AS BIGINT) AS FROMDATE,
			CAST(datetolongC(to_char(date_trunc('day',to_timestamp(getcentertime(ID), 'YYYY-MM-DD HH24:MI:SS')+interval '1' day),'YYYY-MM-DD HH24:MI'), ID) AS BIGINT) AS TODATE,     
             'YYYY-MM-DD HH24:MI:SS' DATETIMEFORMAT,
             time_zone  AS       TZFORMAT
         FROM 
             centers 
   ) 
 SELECT
     c.ID             AS "VISIT_ID",
     c.CHECKIN_CENTER AS "CHECKIN_CENTER_ID",
     cp.EXTERNAL_ID   AS "EXTERNALID",
     p.CENTER         AS "HOME_CENTER_ID",
     TO_CHAR(longtodateC(c.CHECKIN_TIME, c.CHECKIN_CENTER),params.DATETIMEFORMAT)         AS "STARTTIME",
     TO_CHAR(longtodateC(c.CHECKOUT_TIME,c.CHECKIN_CENTER),params.DATETIMEFORMAT)         AS "ENDTIME",
     CASE c.CHECKIN_RESULT
             WHEN 1 THEN  'ACCESS_GRANTED'
             WHEN 2 THEN  'PRESENCE_REGISTERED'
             WHEN 3 THEN  'ACCESS_DENIED'
             ELSE 'UNKNOWN' END AS "CHECKIN_RESULT"
 FROM
     CHECKINS c
 JOIN
    PARAMS
ON
    c.checkin_center = PARAMS.Center  
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
     AND c.CHECKIN_TIME >= PARAMS.FROMDATE
     AND c.CHECKIN_TIME < PARAMS.TODATE
   AND c.checkout_time IS NOT NULL
UNION ALL
     SELECT 
        NULL AS "VISIT_ID",
        NULL AS "CHECKIN_CENTER_ID",
        NULL AS "EXTERNALID",
        NULL AS "HOME_CENTER_ID",
        NULL AS "STARTTIME",
        NULL AS "ENDTIME",
        NULL AS "CHECKIN_RESULT"