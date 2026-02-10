-- The extract is extracted from Exerp on 2026-02-08
--  
WITH PARAMS AS Materialized
 ( 
   SELECT 
     CAST(dateToLongtz(TO_CHAR(trunc(CURRENT_TIMESTAMP -1), 'YYYY-MM-dd HH24:MI'),'Europe/London') AS BIGINT) AS FROMTIME,
     CAST(dateToLongtz(TO_CHAR(trunc(CURRENT_TIMESTAMP), 'YYYY-MM-dd HH24:MI'),'Europe/London')-1 AS BIGINT) AS TOTIME
 )
 SELECT
     DISTINCT CIL.PERSON_CENTER || 'p' || CIL.PERSON_ID
 FROM
     CHECKINS CIL, PARAMS
 WHERE
         CIL.CHECKIN_TIME >=  params.FROMTIME
         AND CIL.CHECKIN_TIME < params.TOTIME
