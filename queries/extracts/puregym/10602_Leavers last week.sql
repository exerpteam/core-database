 WITH
        V_EXCLUDED_SUBSCRIPTIONS AS Materialized
    (
        SELECT
            ppgl.PRODUCT_CENTER as center,
            ppgl.PRODUCT_ID as id
        FROM
            PRODUCT_AND_PRODUCT_GROUP_LINK ppgl
        JOIN
            PRODUCT_GROUP pg
        ON
            pg.ID = ppgl.PRODUCT_GROUP_ID
        WHERE
            pg.EXCLUDE_FROM_MEMBER_COUNT = True
    )
 
 SELECT
     /*+ NO_BIND_AWARE */
     DISTINCT TRUNC(CURRENT_TIMESTAMP - $$offset$$ - 7)           AS From_Date,
     TRUNC(CURRENT_TIMESTAMP - $$offset$$)                        AS To_Date,
     p.CURRENT_PERSON_CENTER||'p'|| p.CURRENT_PERSON_ID AS memberid,
     p1.EXTERNAL_ID,
     p.FULLNAME,
     p.SEX,
     floor(months_between(CURRENT_TIMESTAMP, p.BIRTHDATE) / 12)                                                                                                           AS Age,
     CASE  p.PERSONTYPE  WHEN 0 THEN 'PRIVATE'  WHEN 1 THEN 'STUDENT'  WHEN 2 THEN 'STAFF'  WHEN 3 THEN 'FRIEND'  WHEN 4 THEN 'CORPORATE'  WHEN 5 THEN  'ONEMANCORPORATE'  WHEN 6 THEN  'FAMILY'  WHEN 7 THEN 'SENIOR'  WHEN 8 THEN 'GUEST' ELSE 'UNKNOWN' END AS PersonType,
     pem.TXTVALUE                                                                                                                                               AS email,
     ph.TXTVALUE                                                                                                                                                AS phoneHome,
     pm.TXTVALUE                                                                                                                                                AS mobile,
     COALESCE(ch.this_month,0)                                                                                                                                          this_month,
     COALESCE(ch.last_3_months,0)                                                                                                                                       last_3_months,
     COALESCE(ch.all_checkins,0)                                                                                                                                     AS "Total usage",
     COALESCE(ch.prework,0)                                                                                                                                          prework,
     COALESCE(ch.postwork,0)                                                                                                                                         postwork,
     COALESCE(ch.lunchtime,0)                                                                                                                                        lunchtime,
     CASE
         WHEN s.START_DATE BETWEEN add_months(s.END_DATE,-1) AND s.END_DATE
         THEN sp.PRICE
         ELSE sp2.PRICE
     END                                              AS last_month,
     sp.PRICE                                         AS this_month,
     ROUND(months_between(s.END_DATE,s.START_DATE),0) AS "Membership length Months",
     s.END_DATE-s.START_DATE                          AS "Membership length days",
     TO_CHAR(s.START_DATE,'yyyy-MM-dd')               AS "Membership Start",
     TO_CHAR(s.END_DATE,'yyyy-MM-dd')                 AS "Membership End",
     p.CENTER                                         AS ClubNumber,
     cen.NAME                                         AS ClubName,
     COALESCE(par.num ,0)                             AS "Class usage last 3 months",
     CASE par.induction WHEN 1 THEN 'yes' ELSE 'no' END AS "Induction Participation",
     COALESCE(future.same,0) "future days in same gym",
     COALESCE(future.other,0) "future days in other gyms"
 FROM
     PERSONS p
 JOIN
     PERSONS p1
 ON
     p.CURRENT_PERSON_CENTER = p1.CENTER
     AND p.CURRENT_PERSON_ID = p1.ID
 JOIN
     SUBSCRIPTIONS s
 ON
     s.OWNER_CENTER = p.center
     AND s.OWNER_ID = p.id
     AND s.END_DATE BETWEEN TRUNC(CURRENT_TIMESTAMP - $$offset$$ - 7) AND TRUNC(CURRENT_TIMESTAMP - $$offset$$)
     AND s.END_DATE >= s.START_DATE
     AND s.SUB_STATE != 6
 JOIN
     SUBSCRIPTIONTYPES st
 ON
     st.CENTER = s.SUBSCRIPTIONTYPE_CENTER
     AND st.id = s.SUBSCRIPTIONTYPE_ID
     AND (ST.CENTER, ST.ID) not in (select center, id from V_EXCLUDED_SUBSCRIPTIONS)
 LEFT JOIN
     SUBSCRIPTION_PRICE sp
 ON
     sp.SUBSCRIPTION_CENTER = s.CENTER
     AND sp.SUBSCRIPTION_ID = s.id
     AND sp.FROM_DATE<=s.END_DATE
     AND (
         sp.TO_DATE >=s.END_DATE
         OR sp.TO_DATE IS NULL )
     AND sp.CANCELLED =0
 LEFT JOIN
     SUBSCRIPTION_PRICE sp2
 ON
     sp2.SUBSCRIPTION_CENTER = s.CENTER
     AND sp2.SUBSCRIPTION_ID = s.id
     AND sp2.FROM_DATE<add_months(s.END_DATE,-1)
     AND (
         sp2.TO_DATE >=add_months(s.END_DATE,-1)
         OR sp2.TO_DATE IS NULL )
     AND sp2.CANCELLED =0
 LEFT JOIN
     (
         SELECT
             p.CURRENT_PERSON_CENTER,
             p.CURRENT_PERSON_ID,
             SUM(
                 CASE
                     WHEN EXTRACT(HOUR FROM longtodate(ch.CHECKIN_TIME)) BETWEEN 6 AND 9
                         AND longtodate(ch.CHECKIN_TIME) BETWEEN TRUNC(add_months(s.END_DATE,-3)) AND s.END_DATE
                     THEN 1
                     ELSE 0
                 END) AS prework,
             SUM(
                 CASE
                     WHEN EXTRACT(HOUR FROM longtodate(ch.CHECKIN_TIME)) BETWEEN 17 AND 20
                         AND longtodate(ch.CHECKIN_TIME) BETWEEN TRUNC(add_months(s.END_DATE,-3)) AND s.END_DATE
                     THEN 1
                     ELSE 0
                 END) AS postwork,
             SUM(
                 CASE
                     WHEN EXTRACT(HOUR FROM longtodate(ch.CHECKIN_TIME)) BETWEEN 12 AND 14
                         AND longtodate(ch.CHECKIN_TIME) BETWEEN TRUNC(add_months(s.END_DATE,-3)) AND s.END_DATE
                     THEN 1
                     ELSE 0
                 END) AS lunchtime,
             SUM(
                 CASE
                     WHEN longtodate(ch.CHECKIN_TIME) BETWEEN TRUNC(add_months(s.END_DATE,-1)) AND s.END_DATE
                     THEN 1
                     ELSE 0
                 END) AS this_month,
             SUM(
                 CASE
                     WHEN longtodate(ch.CHECKIN_TIME) BETWEEN TRUNC(add_months(s.END_DATE,-3)) AND s.END_DATE
                     THEN 1
                     ELSE 0
                 END) AS last_3_months,
             COUNT(*) AS all_checkins
         FROM
             PERSONS p
         JOIN
             PERSONS p2
         ON
             p2.CURRENT_PERSON_CENTER = p.CURRENT_PERSON_CENTER
             AND p2.CURRENT_PERSON_ID = p.CURRENT_PERSON_ID
         JOIN
             CHECKINS ch
         ON
             p2.CENTER = ch.PERSON_CENTER
             AND p2.id = ch.PERSON_ID
         JOIN
             SUBSCRIPTIONS s
         ON
             s.OWNER_CENTER = p.center
             AND s.OWNER_ID = p.id
             AND s.END_DATE BETWEEN TRUNC(CURRENT_TIMESTAMP - $$offset$$ - 7) AND TRUNC(CURRENT_TIMESTAMP - $$offset$$)
             AND s.END_DATE >= s.START_DATE
             AND s.SUB_STATE != 6
         JOIN
             SUBSCRIPTIONTYPES st
         ON
             st.CENTER = s.SUBSCRIPTIONTYPE_CENTER
             AND st.id = s.SUBSCRIPTIONTYPE_ID
             AND (ST.CENTER, ST.ID) not in (select center, id from V_EXCLUDED_SUBSCRIPTIONS)
         WHERE
             p2.LAST_ACTIVE_START_DATE IS NOT NULL
             AND p.center IN ($$scope$$)
         GROUP BY
             p.CURRENT_PERSON_CENTER,
             p.CURRENT_PERSON_ID) ch
 ON
     ch.CURRENT_PERSON_CENTER = p.CURRENT_PERSON_CENTER
     AND ch.CURRENT_PERSON_ID = p.CURRENT_PERSON_ID
 LEFT JOIN
     (
         SELECT
             p.CURRENT_PERSON_CENTER,
             p.CURRENT_PERSON_ID,
             COUNT(DISTINCT par.CENTER||'par'||par.id) AS num,
             MAX(CASE ac.ACTIVITY_GROUP_ID WHEN 203 THEN 1 ELSE 0 END) AS induction
         FROM
             PARTICIPATIONS par
         JOIN
             PERSONS p
         ON
             p.CENTER = par.PARTICIPANT_CENTER
             AND p.id = par.PARTICIPANT_ID
         JOIN
             SUBSCRIPTIONS s
         ON
             s.OWNER_CENTER = p.center
             AND s.OWNER_ID = p.id
             AND s.END_DATE BETWEEN TRUNC(CURRENT_TIMESTAMP - $$offset$$ - 7) AND TRUNC(CURRENT_TIMESTAMP - $$offset$$)
             AND s.END_DATE >= s.START_DATE
             AND s.SUB_STATE != 6
         JOIN
             SUBSCRIPTIONTYPES st
         ON
             st.CENTER = s.SUBSCRIPTIONTYPE_CENTER
             AND st.id = s.SUBSCRIPTIONTYPE_ID
             AND (ST.CENTER, ST.ID) not in (select center, id from V_EXCLUDED_SUBSCRIPTIONS)
         JOIN
             BOOKINGS bo
         ON
             bo.CENTER = par.BOOKING_CENTER
             AND bo.id = par.BOOKING_ID
         JOIN
             ACTIVITY ac
         ON
             ac.ID = bo.ACTIVITY
         WHERE
             par.STATE='PARTICIPATION'
             AND p.center IN ($$scope$$)
             AND par.START_TIME BETWEEN dateToLongtz(TO_CHAR(TRUNC(add_months(s.END_DATE, -3)), 'YYYY-MM-dd HH24:MI'),'Europe/London') AND dateToLongtz(TO_CHAR(s.END_DATE, 'YYYY-MM-dd HH24:MI'), 'Europe/London')
         GROUP BY
             p.CURRENT_PERSON_CENTER,
             p.CURRENT_PERSON_ID) par
 ON
     par.CURRENT_PERSON_CENTER = p.CURRENT_PERSON_CENTER
     AND par.CURRENT_PERSON_ID = p.CURRENT_PERSON_ID
 LEFT JOIN
     (
         SELECT DISTINCT
             p.CURRENT_PERSON_CENTER,
             p.CURRENT_PERSON_ID,
             s.center,
             s.id,
             ROUND(SUM(
                 CASE
                     WHEN s2.center = s.center
                         AND s2.END_DATE < CURRENT_TIMESTAMP
                     THEN s2.END_DATE - s2.START_DATE
                     WHEN s2.center = s.center
                         AND (s2.END_DATE >= CURRENT_TIMESTAMP
                             OR s2.END_DATE IS NULL)
                     THEN CURRENT_DATE  - s2.START_DATE
                 END),0) AS same,
             ROUND(SUM(
                 CASE
                     WHEN s2.center != s.center
                         AND s2.END_DATE < CURRENT_TIMESTAMP
                     THEN s2.END_DATE - s2.START_DATE
                     WHEN s2.center != s.center
                         AND (s2.END_DATE >= CURRENT_TIMESTAMP
                             OR s2.END_DATE IS NULL )
                     THEN CURRENT_DATE - s2.START_DATE
                 END),0) AS other
         FROM
             PERSONS p
         JOIN
             PERSONS p1
         ON
             p1.CURRENT_PERSON_CENTER = p.CURRENT_PERSON_CENTER
             AND p1.CURRENT_PERSON_ID = p.CURRENT_PERSON_ID
         JOIN
             SUBSCRIPTIONS s
         ON
             s.OWNER_CENTER = p.center
             AND s.OWNER_ID = p.id
             AND s.END_DATE BETWEEN TRUNC(CURRENT_TIMESTAMP - $$offset$$ - 7) AND TRUNC(CURRENT_TIMESTAMP - $$offset$$)
             AND s.END_DATE >= s.START_DATE
             AND s.SUB_STATE != 6
         JOIN
             SUBSCRIPTIONTYPES st
         ON
             st.CENTER = s.SUBSCRIPTIONTYPE_CENTER
             AND st.id = s.SUBSCRIPTIONTYPE_ID
             AND (ST.CENTER, ST.ID) not in (select center, id from V_EXCLUDED_SUBSCRIPTIONS)
         JOIN
             SUBSCRIPTIONS s2
         ON
             s2.OWNER_CENTER = p1.center
             AND s2.OWNER_ID = p1.id
             AND (
                 s2.END_DATE >s.END_DATE
                 OR s2.END_DATE IS NULL )
             AND s2.END_DATE >= s2.START_DATE
         JOIN
             SUBSCRIPTIONTYPES st2
         ON
             st2.CENTER = s2.SUBSCRIPTIONTYPE_CENTER
             AND st2.id = s2.SUBSCRIPTIONTYPE_ID
             AND (ST2.CENTER, ST2.ID) not in (select center, id from V_EXCLUDED_SUBSCRIPTIONS)
         WHERE
             p.center IN ($$scope$$)
         GROUP BY
             p.CURRENT_PERSON_CENTER,
             p.CURRENT_PERSON_ID,
             s.center,
             s.id) future
 ON
     future.CURRENT_PERSON_CENTER = p.CURRENT_PERSON_CENTER
     AND future.CURRENT_PERSON_ID=p.CURRENT_PERSON_ID
     AND future.center = s.center
     AND future.id = s.id
 LEFT JOIN
     person_ext_attrs ph
 ON
     ph.personcenter = p.center
     AND ph.personid = p.id
     AND ph.name = '_eClub_PhoneHome'
 LEFT JOIN
     person_ext_attrs pem
 ON
     pem.personcenter = p.center
     AND pem.personid = p.id
     AND pem.name = '_eClub_Email'
 LEFT JOIN
     person_ext_attrs pm
 ON
     pm.personcenter = p.center
     AND pm.personid = p.id
     AND pm.name = '_eClub_PhoneSMS'
 JOIN
     CENTERS cen
 ON
     cen.Id = p.CENTER
 WHERE
     s.center IN ($$scope$$)
