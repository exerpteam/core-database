-- The extract is extracted from Exerp on 2026-02-08
-- ST-2415
 SELECT
    TO_CHAR(longToDateC(att.START_TIME,att.CENTER),'DD.MM.YYYY HH24:MI') AS "Date and time"
   ,p.center || 'p' || p.id  AS "Member ID"
   , p.FULLNAME AS "Fuul name"
   , att.CENTER AS "Center ID"
   ,c.NAME      AS "Center Name"
   ,prod.NAME   AS "Subscription"
   ,to_char(longtodateC(att.START_TIME, att.CENTER), 'Day')  AS "Weekday",
    CASE
       WHEN att.PERSON_CENTER = att.BOOKING_RESOURCE_CENTER THEN 1
       ELSE 0
    END "Local Visits",
    CASE
         WHEN att.PERSON_CENTER <> att.BOOKING_RESOURCE_CENTER THEN 1
         ELSE 0
    END "Guest Visits",
   1 AS "Visits"
 FROM
     PRIVILEGE_USAGES pu
 LEFT JOIN
     SUBSCRIPTIONS s
 ON
     s.CENTER = pu.SOURCE_CENTER
     AND s.id = pu.SOURCE_ID
 LEFT JOIN
     PRODUCTS prod
 ON
     prod.CENTER = s.SUBSCRIPTIONTYPE_CENTER
     AND prod.id = s.SUBSCRIPTIONTYPE_ID
 JOIN
     BOOKING_PRIVILEGES bp
 ON
     bp.ID = pu.PRIVILEGE_ID
 JOIN
     BOOKING_PRIVILEGE_GROUPS bpg
 ON
     bpg.ID = bp.GROUP_ID
 JOIN
     ATTENDS att
 ON
     att.CENTER = pu.TARGET_CENTER
     AND att.ID = pu.TARGET_ID
 JOIN
     PERSONS p
 ON
     p.CENTER = att.PERSON_CENTER
     AND p.id = att.PERSON_ID
 JOIN
     CENTERS c
 ON
     c.id = att.CENTER
 WHERE
     pu.PRIVILEGE_TYPE = 'BOOKING'
     AND pu.TARGET_SERVICE = 'Attend'
     AND bpg.NAME = $$access_group$$
     AND att.START_TIME BETWEEN $$date_from$$ AND $$date_to$$
     AND att.center IN ($$scope$$)
