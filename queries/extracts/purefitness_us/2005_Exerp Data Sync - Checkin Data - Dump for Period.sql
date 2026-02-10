-- The extract is extracted from Exerp on 2026-02-08
--  
WITH
  params AS materialized
     (
         SELECT
             id   AS  center,
             CAST(datetolongC(TO_CHAR(CAST($$fromdate$$ AS DATE), 'YYYY-MM-DD HH24:MI'), id) AS BIGINT) AS FROMDATE,
             CAST(datetolongC(TO_CHAR(CAST($$todate$$ AS DATE), 'YYYY-MM-DD HH24:MI'), id) AS BIGINT) + (86400 * 1000) AS TODATE,
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
    c.CHECKIN_CENTER in ($$scope$$)
    AND c.CHECKIN_TIME >= params.FROMDATE
    AND c.CHECKIN_TIME < params.TODATE
    AND c.CHECKOUT_TIME is not null 
	