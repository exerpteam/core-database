-- The extract is extracted from Exerp on 2026-02-08
-- https://clublead.atlassian.net/browse/ST-2238
https://clublead.atlassian.net/browse/ST-3947
 SELECT
         t1.*
 FROM
 (
 SELECT
             *
         FROM
             (
                 SELECT
                     FULLNAME ,
                     BIRTHDATE ,
                     PID ,
                     SUBSCRIPTION ,
                     CHECKIN_DATE ,
                     CHECKIN_TIME ,
                     CHECKOUT_TIME ,
                     RESOURCES_USED ,
                     CLUB_NAME,
 CASE  persontype  WHEN 0 THEN 'Private'  WHEN 1 THEN 'Student'  WHEN 2 THEN 'Staff'  WHEN 3 THEN 'Friend'  WHEN 4 THEN 'Corporate'  WHEN 5 THEN 'Onemancorporate'  WHEN 6 THEN 'Family'
                      WHEN 7 THEN 'Senior'  WHEN 8 THEN 'Guest'  WHEN 9 THEN  'Child'  WHEN 10 THEN  'External_Staff' ELSE 'Unknown' END AS PERSON_TYPE,
                     COUNT(*) over(PARTITION BY PID ) AS CHECKIN_COUNT,
                     COUNT(CLUB_NAME) over(PARTITION BY PID) AS CLUB_COUNT
                 FROM
                     (
                         WITH
                             params AS
                             (
                                 SELECT
                                     /*+ materialize */
                                     $$from_date$$ AS PREV_DAY ,
                                     $$to_date$$ AS TODAY
                                 
                             )
                         SELECT DISTINCT
                             p.FULLNAME ,
                             p.BIRTHDATE ,
                                                         p.persontype,
                             c.PERSON_CENTER || 'p' || c.PERSON_ID                             pid ,
                             prod.NAME                                                         AS subscription ,
                             TO_CHAR(longToDateC(c.CHECKIN_TIME,c.PERSON_CENTER),'YYYY-MM-DD') CHECKIN_DATE ,
                             TO_CHAR(longToDateC(c.CHECKIN_TIME,c.PERSON_CENTER),'HH24:MI')    CHECKIN_TIME ,
                             TO_CHAR(longToDateC(c.CHECKOUT_TIME,c.PERSON_CENTER),'HH24:MI')   CHECKOUT_TIME ,
                             CASE
                                 WHEN c.CHECKIN_TIME - LEAD(c.CHECKOUT_TIME) OVER (PARTITION BY c.PERSON_CENTER,c.PERSON_ID ORDER BY c.CHECKIN_TIME DESC) >= (1000 * 60 * 60 * 2)
                                     AND TRUNC(longToDateC(c.CHECKIN_TIME,c.CHECKIN_CENTER)) = TRUNC(longToDateC(LEAD(c.CHECKIN_TIME) OVER (PARTITION BY c.PERSON_CENTER,c.PERSON_ID ORDER BY c.CHECKIN_TIME DESC),c.CHECKIN_CENTER))
                                 THEN 1
                                 ELSE 0
                             END DIFF_FROM_PREV_ROW_OK ,
                             CASE
                                 WHEN LAG(c.CHECKIN_TIME) OVER (PARTITION BY c.PERSON_CENTER,c.PERSON_ID ORDER BY c.CHECKIN_TIME DESC) - c.CHECKOUT_TIME >= (1000 * 60 * 60 * 2)
                                     AND TRUNC(longToDateC(c.CHECKIN_TIME,c.CHECKIN_CENTER)) = TRUNC(longToDateC(LAG(c.CHECKIN_TIME) OVER (PARTITION BY c.PERSON_CENTER,c.PERSON_ID ORDER BY c.CHECKIN_TIME DESC),c.CHECKIN_CENTER))
                                 THEN 1
                                 ELSE 0
                             END                                                                                          DIFF_FROM_NEXT_ROW_OK ,
                             string_agg(br.name ,' / ' )  OVER (PARTITION BY c.ID ORDER BY att.START_TIME DESC) AS RESOURCES_USED ,
                             cen.SHORTNAME                                                                                CLUB_NAME
                             --  ,LEAD(longToDateC(c.CHECKOUT_TIME,c.PERSON_CENTER)) OVER (PARTITION BY c.PERSON_CENTER,c.PERSON_ID ORDER BY c.CHECKIN_TIME desc) PREV_CHECKOUT
                             --  ,LAG(longToDateC(c.CHECKIN_TIME,c.PERSON_CENTER)) OVER (PARTITION BY c.PERSON_CENTER,c.PERSON_ID ORDER BY c.CHECKIN_TIME desc) NEXT_CHECKIN
                             --  ,LEAD(c.CHECKOUT_TIME) OVER (PARTITION BY c.PERSON_CENTER,c.PERSON_ID ORDER BY c.CHECKIN_TIME desc) PREV_CHECKOUT_LONG
                             --  ,LAG(c.CHECKIN_TIME) OVER (PARTITION BY c.PERSON_CENTER,c.PERSON_ID ORDER BY c.CHECKIN_TIME desc) NEXT_CHECKIN_LONG
                         FROM
                             CHECKINS c
                         CROSS JOIN
                             PARAMS
                         LEFT JOIN
                             ATTENDS att
                         ON
                             att.PERSON_CENTER = c.PERSON_CENTER
                             AND att.PERSON_ID = c.PERSON_ID
                             AND att.STATE = 'ACTIVE'
                             AND att.START_TIME BETWEEN c.CHECKIN_TIME AND c.CHECKOUT_TIME
                         LEFT JOIN
                             BOOKING_RESOURCES br
                         ON
                             br.CENTER = att.BOOKING_RESOURCE_CENTER
                             AND br.ID = att.BOOKING_RESOURCE_ID
                         JOIN
                             CENTERS cen
                         ON
                             cen.ID = c.CHECKIN_CENTER
                         JOIN
                             PERSONS p
                         ON
                             p.CENTER = c.PERSON_CENTER
                             AND p.ID = c.PERSON_ID
                         LEFT JOIN
                             SUBSCRIPTIONS s
                         ON
                             s.OWNER_CENTER = p.CENTER
                             AND s.OWNER_ID = p.ID
                             AND s.STATE IN (2,4,8)
                         LEFT JOIN
                             PRODUCTS prod
                         ON
                             prod.CENTER = s.SUBSCRIPTIONTYPE_CENTER
                             AND prod.ID = s.SUBSCRIPTIONTYPE_ID
                         WHERE
                             c.CHECKIN_TIME >= PARAMS.PREV_DAY
                             AND c.CHECKIN_TIME < PARAMS.TODAY
                             AND c.PERSON_CENTER IN ($$scope$$)
                             --AND p.PERSONTYPE = 2
                             AND p.PERSONTYPE::varchar IN ($$personType$$)
                             ) t
                 WHERE
                     (
                         DIFF_FROM_PREV_ROW_OK = 1
                         OR DIFF_FROM_NEXT_ROW_OK = 1)
                 ORDER BY
                     pid,
                     CHECKIN_DATE,
                     CHECKIN_TIME) t2
                     where CHECKIN_COUNT >= $$Count$$
 ) t1
 WHERE t1.CLUB_COUNT >= $$ClubCount$$
