 SELECT
     longToDateC(att.START_TIME,att.CENTER) "Date and time"
   ,p.center || 'p' || p.id member_id
   , p.FULLNAME
   , att.CENTER center_id
   ,c.NAME      center_name
   ,prod.NAME as  subscription
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
