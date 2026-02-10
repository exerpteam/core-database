-- The extract is extracted from Exerp on 2026-02-08
-- https://clublead.atlassian.net/browse/ST-7271
 SELECT
     p.EXTERNAL_ID                                  AS "External ref",
     CASE c.IDENTITY_METHOD  WHEN 5 THEN  'PIN'  WHEN 7 THEN  'QR' END   AS "PIN/QR flag",
     TO_CHAR(longtodateC(c.CHECKIN_TIME,c.CHECKIN_CENTER),'DD/MM/YY HH24:MI:SS')   AS "Checkin Time",
     TO_CHAR(longtodateC(c.CHECKOUT_TIME,c.CHECKIN_CENTER),'DD/MM/YY HH24:MI:SS')   AS "Checkout Time"
 FROM
     checkins c
 JOIN
     PERSONS p
 ON
     c.PERSON_CENTER = p.CENTER
     AND c.PERSON_ID = p.ID
 WHERE
     c.CHECKIN_TIME >= :From_Date
     AND c.CHECKIN_TIME < :From_To + 24*3600*1000
     AND c.CHECKIN_CENTER in (:Centers)
