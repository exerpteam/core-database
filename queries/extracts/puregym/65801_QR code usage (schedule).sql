-- The extract is extracted from Exerp on 2026-02-08
--  
 WITH PARAMS as MATERIALIZED
 (
      SELECT
        datetolongTZ(TO_CHAR(TRUNC(current_timestamp-1, 'DDD'), 'YYYY-MM-DD HH24:MI'),   'Europe/London') AS FROM_DATETIME,
        datetolongTZ(TO_CHAR(TRUNC(current_timestamp, 'DDD'), 'YYYY-MM-DD HH24:MI'),   'Europe/London') AS TO_DATETIME
    
 )
 SELECT
     p.EXTERNAL_ID                                  AS "External ref",
     CASE c.IDENTITY_METHOD  WHEN 5 THEN  'PIN'  WHEN 7 THEN  'QR' END   AS "PIN/QR flag",
     TO_CHAR(longtodateC(c.CHECKIN_TIME,c.CHECKIN_CENTER),'DD/MM/YY HH24:MI:SS')   AS "Checkin Time",
     TO_CHAR(longtodateC(c.CHECKOUT_TIME,c.CHECKIN_CENTER),'DD/MM/YY HH24:MI:SS')   AS "Checkout Time"
 FROM
     params, checkins c
 JOIN
     PERSONS p
 ON
     c.PERSON_CENTER = p.CENTER
     AND c.PERSON_ID = p.ID
 WHERE
     c.CHECKIN_TIME >= params.FROM_DATETIME
     AND c.CHECKIN_TIME < params.TO_DATETIME
     AND c.CHECKIN_CENTER in (:Centers)
