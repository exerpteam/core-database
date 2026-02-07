SELECT
    /*+ NO_BIND_AWARE */
    DISTINCT TRUNC(SYSDATE - $$Offset$$ -7) AS From_Date,
    TRUNC(SYSDATE - $$Offset$$)             AS To_Date,
    p.center||'p'|| p.id                    AS memberid,
    p1.EXTERNAL_ID,
    p.FULLNAME ,
    p.SEX,
    floor(months_between(SYSDATE, p.BIRTHDATE) / 12)                                                                                                           AS Age,
    DECODE ( p.PERSONTYPE, 0,'PRIVATE', 1,'STUDENT', 2,'STAFF', 3,'FRIEND', 4,'CORPORATE', 5, 'ONEMANCORPORATE', 6, 'FAMILY', 7,'SENIOR', 8,'GUEST','UNKNOWN') AS PersonType,
    pem.TXTVALUE                                                                                                                                               AS email,
    ph.TXTVALUE                                                                                                                                                AS phoneHome,
    pm.TXTVALUE                                                                                                                                                AS mobile,
    NVL(ch.this_month,0)                                                                                                                                          first_month,
    NVL(ch.last_3_months,0)                                                                                                                                       first_3_months,
    NVL(ch.all_checkins,0)                                                                                                                                     AS "Total usage",
    NVL(ch.prework,0)                                                                                                                                             prework,
    NVL(ch.postwork,0)                                                                                                                                            postwork,
    NVL(ch.lunchtime,0)                                                                                                                                           lunchtime,
    sp2.PRICE                                                                                                                                                  AS second_month,
    sp.PRICE                                                                                                                                                   AS first_month,
    ROUND(months_between(s.END_DATE,s.START_DATE),0)                                                                                                           AS "Membership length Months",
    s.END_DATE-s.START_DATE                                                                                                                                    AS "Membership length days",
    TO_CHAR(s.START_DATE,'yyyy-MM-dd')                                                                                                                         AS "Membership Start",
    TO_CHAR(s.END_DATE,'yyyy-MM-dd')                                                                                                                           AS "Membership End",
    p.CENTER                                                                                                                                                   AS ClubNumber,
    cen.NAME                                                                                                                                                   AS ClubName,
    NVL(par.num ,0)                                                                                                                                            AS "Class usage first 3 months",
    DECODE(par.induction,1,'yes','no')                                                                                                                         AS "Induction Participation"
FROM
    PUREGYM.PERSONS p
JOIN
    PUREGYM.PERSONS p1
ON
    p.CURRENT_PERSON_CENTER = p1.CENTER
    AND p.CURRENT_PERSON_ID = p1.ID
JOIN
    PUREGYM.SUBSCRIPTIONS s
ON
    s.OWNER_CENTER = p.center
    AND s.OWNER_ID = p.id
    AND s.START_DATE BETWEEN TRUNC(SYSDATE - $$Offset$$-7) AND TRUNC(SYSDATE - $$Offset$$)
    AND (
        s.END_DATE >= s.START_DATE
        OR s.END_DATE IS NULL)
JOIN
    PUREGYM.SUBSCRIPTIONTYPES st
ON
    st.CENTER = s.SUBSCRIPTIONTYPE_CENTER
    AND st.id = s.SUBSCRIPTIONTYPE_ID
    AND (ST.CENTER, ST.ID) not in (select center, id from V_EXCLUDED_SUBSCRIPTIONS) 
LEFT JOIN
    PUREGYM.SUBSCRIPTION_PRICE sp
ON
    sp.SUBSCRIPTION_CENTER = s.CENTER
    AND sp.SUBSCRIPTION_ID = s.id
    AND sp.FROM_DATE=s.START_DATE
    AND sp.CANCELLED =0
LEFT JOIN
    PUREGYM.SUBSCRIPTION_PRICE sp2
ON
    sp2.SUBSCRIPTION_CENTER = s.CENTER
    AND sp2.SUBSCRIPTION_ID = s.id
    AND sp2.FROM_DATE<=add_months(s.START_DATE,1)
    AND (
        sp2.TO_DATE >=add_months(s.START_DATE,1)
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
                        AND longtodate(ch.CHECKIN_TIME) BETWEEN s.START_DATE AND TRUNC(add_months(s.START_DATE,3))
                    THEN 1
                    ELSE 0
                END) AS prework,
            SUM(
                CASE
                    WHEN EXTRACT(HOUR FROM longtodate(ch.CHECKIN_TIME)) BETWEEN 17 AND 20
                        AND longtodate(ch.CHECKIN_TIME) BETWEEN s.START_DATE AND TRUNC(add_months(s.START_DATE,3))
                    THEN 1
                    ELSE 0
                END) AS postwork,
            SUM(
                CASE
                    WHEN EXTRACT(HOUR FROM longtodate(ch.CHECKIN_TIME)) BETWEEN 12 AND 14
                        AND longtodate(ch.CHECKIN_TIME) BETWEEN s.START_DATE AND TRUNC(add_months(s.START_DATE,3))
                    THEN 1
                    ELSE 0
                END) AS lunchtime,
            SUM(
                CASE
                    WHEN longtodate(ch.CHECKIN_TIME) BETWEEN s.START_DATE AND TRUNC(add_months(s.START_DATE,1))
                    THEN 1
                    ELSE 0
                END) AS this_month,
            SUM(
                CASE
                    WHEN longtodate(ch.CHECKIN_TIME) BETWEEN s.START_DATE AND TRUNC(add_months(s.START_DATE,3))
                    THEN 1
                    ELSE 0
                END) AS last_3_months,
            COUNT(*) AS all_checkins
        FROM
            PUREGYM.CHECKINS ch
        JOIN
            PUREGYM.PERSONS p
        ON
            p.CENTER = ch.PERSON_CENTER
            AND p.id = ch.PERSON_ID
        JOIN
            PUREGYM.SUBSCRIPTIONS s
        ON
            s.OWNER_CENTER = p.center
            AND s.OWNER_ID = p.id
            AND s.START_DATE BETWEEN TRUNC(SYSDATE - $$Offset$$-7) AND TRUNC(SYSDATE - $$Offset$$)
            AND (
                s.END_DATE >= s.START_DATE
                OR s.END_DATE IS NULL)
        JOIN
            PUREGYM.SUBSCRIPTIONTYPES st
        ON
            st.CENTER = s.SUBSCRIPTIONTYPE_CENTER
            AND st.id = s.SUBSCRIPTIONTYPE_ID
            AND (ST.CENTER, ST.ID) not in (select center, id from V_EXCLUDED_SUBSCRIPTIONS) 
        WHERE
            p.center IN ($$scope$$)
            AND NOT EXISTS
            (
                SELECT
                    1
                FROM
                    PUREGYM.SUBSCRIPTIONS s2
                JOIN
                    PUREGYM.SUBSCRIPTIONTYPES st2
                ON
                    st2.CENTER = s2.SUBSCRIPTIONTYPE_CENTER
                    AND st2.id = s2.SUBSCRIPTIONTYPE_ID
                    AND (ST2.CENTER, ST2.ID) not in (select center, id from V_EXCLUDED_SUBSCRIPTIONS) 
                JOIN
                    PUREGYM.PERSONS p3
                ON
                    p3.center = s2.OWNER_CENTER
                    AND p3.id = s2.OWNER_ID
                WHERE
                    p3.CURRENT_PERSON_CENTER = p.CENTER
                    AND p3.CURRENT_PERSON_ID = p.id
                    AND (
                        s2.START_DATE < s.START_DATE ))
        GROUP BY
            p.CURRENT_PERSON_CENTER,
            p.CURRENT_PERSON_ID) ch
ON
    ch.CURRENT_PERSON_CENTER = p.CENTER
    AND ch.CURRENT_PERSON_ID = p.ID
LEFT JOIN
    (
        SELECT
            p.CURRENT_PERSON_CENTER,
            p.CURRENT_PERSON_ID,
            COUNT(DISTINCT par.CENTER||'par'||par.id) AS num,
            MAX(DECODE(ac.ACTIVITY_GROUP_ID,203,1,0)) AS induction
        FROM
            PUREGYM.PARTICIPATIONS par
        JOIN
            PUREGYM.PERSONS p
        ON
            p.CENTER = par.PARTICIPANT_CENTER
            AND p.id = par.PARTICIPANT_ID
        JOIN
            PUREGYM.SUBSCRIPTIONS s
        ON
            s.OWNER_CENTER = p.center
            AND s.OWNER_ID = p.id
            AND s.START_DATE BETWEEN TRUNC(SYSDATE - $$Offset$$-7) AND TRUNC(SYSDATE - $$Offset$$)
            AND (
                s.END_DATE >= s.START_DATE
                OR s.END_DATE IS NULL)
        JOIN
            PUREGYM.SUBSCRIPTIONTYPES st
        ON
            st.CENTER = s.SUBSCRIPTIONTYPE_CENTER
            AND st.id = s.SUBSCRIPTIONTYPE_ID
            AND (ST.CENTER, ST.ID) not in (select center, id from V_EXCLUDED_SUBSCRIPTIONS) 
        JOIN
            PUREGYM.BOOKINGS bo
        ON
            bo.CENTER = par.BOOKING_CENTER
            AND bo.id = par.BOOKING_ID
        JOIN
            PUREGYM.ACTIVITY ac
        ON
            ac.ID = bo.ACTIVITY
        WHERE
            par.STATE='PARTICIPATION'
            AND p.center IN ($$scope$$)
            AND par.START_TIME BETWEEN dateToLongtz(TO_CHAR(s.START_DATE, 'YYYY-MM-dd HH24:MI'), 'Europe/London') AND dateToLongtz(TO_CHAR(TRUNC(add_months(s.START_DATE, 3)), 'YYYY-MM-dd HH24:MI'),'Europe/London')
            AND NOT EXISTS
            (
                SELECT
                    1
                FROM
                    PUREGYM.SUBSCRIPTIONS s2
                JOIN
                    PUREGYM.SUBSCRIPTIONTYPES st2
                ON
                    st2.CENTER = s2.SUBSCRIPTIONTYPE_CENTER
                    AND st2.id = s2.SUBSCRIPTIONTYPE_ID
                    AND (ST2.CENTER, ST2.ID) not in (select center, id from V_EXCLUDED_SUBSCRIPTIONS) 
                JOIN
                    PUREGYM.PERSONS p3
                ON
                    p3.center = s2.OWNER_CENTER
                    AND p3.id = s2.OWNER_ID
                WHERE
                    p3.CURRENT_PERSON_CENTER = p.CENTER
                    AND p3.CURRENT_PERSON_ID = p.id
                    AND (
                        s2.START_DATE < s.START_DATE ))
        GROUP BY
            p.CURRENT_PERSON_CENTER,
            p.CURRENT_PERSON_ID) par
ON
    par.CURRENT_PERSON_CENTER = p.CENTER
    AND par.CURRENT_PERSON_ID = p.id
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
    PUREGYM.CENTERS cen
ON
    cen.Id = p.CENTER
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
                        AND s2.END_DATE < SYSDATE
                    THEN s2.END_DATE - s2.START_DATE
                    WHEN s2.center = s.center
                        AND (s2.END_DATE >= SYSDATE
                            OR s2.END_DATE IS NULL)
                    THEN SYSDATE - s2.START_DATE
                END),0) AS same,
            ROUND(SUM(
                CASE
                    WHEN s2.center != s.center
                        AND s2.END_DATE < SYSDATE
                    THEN s2.END_DATE - s2.START_DATE
                    WHEN s2.center != s.center
                        AND (s2.END_DATE >= SYSDATE
                            OR s2.END_DATE IS NULL )
                    THEN SYSDATE - s2.START_DATE
                END),0)       AS other,
            COUNT(scl.CENTER) AS rejoins
        FROM
            PUREGYM.PERSONS p
        JOIN
            PUREGYM.PERSONS p1
        ON
            p1.CURRENT_PERSON_CENTER = p.CURRENT_PERSON_CENTER
            AND p1.CURRENT_PERSON_ID = p.CURRENT_PERSON_ID
        JOIN
            PUREGYM.SUBSCRIPTIONS s
        ON
            s.OWNER_CENTER = p.center
            AND s.OWNER_ID = p.id
            AND s.START_DATE BETWEEN TRUNC(SYSDATE - $$Offset$$-7) AND TRUNC(SYSDATE - $$Offset$$)
            AND (
                s.END_DATE >= s.START_DATE
                OR s.END_DATE IS NULL)
        JOIN
            PUREGYM.SUBSCRIPTIONTYPES st
        ON
            st.CENTER = s.SUBSCRIPTIONTYPE_CENTER
            AND st.id = s.SUBSCRIPTIONTYPE_ID
            AND (ST.CENTER, ST.ID) not in (select center, id from V_EXCLUDED_SUBSCRIPTIONS) 
        JOIN
            PUREGYM.SUBSCRIPTIONS s2
        ON
            s2.OWNER_CENTER = p1.center
            AND s2.OWNER_ID = p1.id
            AND (
                s2.END_DATE >s.END_DATE
                OR s2.END_DATE IS NULL )
            AND s2.END_DATE >= s2.START_DATE
        JOIN
            PUREGYM.SUBSCRIPTIONTYPES st2
        ON
            st2.CENTER = s2.SUBSCRIPTIONTYPE_CENTER
            AND st2.id = s2.SUBSCRIPTIONTYPE_ID
            AND (ST2.CENTER, ST2.ID) not in (select center, id from V_EXCLUDED_SUBSCRIPTIONS) 
        LEFT JOIN
            PUREGYM.STATE_CHANGE_LOG scl
        ON
            scl.CENTER = s2.CENTER
            AND scl.id = s2.id
            AND scl.ENTRY_TYPE = 2
            AND scl.STATEID = 8
            AND scl.SUB_STATE NOT IN (3,4,6)
        WHERE
            p.center IN ($$scope$$)
            AND NOT EXISTS
            (
                SELECT
                    1
                FROM
                    PUREGYM.SUBSCRIPTIONS s3
                JOIN
                    PUREGYM.SUBSCRIPTIONTYPES st3
                ON
                    st3.CENTER = s3.SUBSCRIPTIONTYPE_CENTER
                    AND st3.id = s3.SUBSCRIPTIONTYPE_ID
                    AND (ST3.CENTER, ST3.ID) not in (select center, id from V_EXCLUDED_SUBSCRIPTIONS) 
                JOIN
                    PUREGYM.PERSONS p3
                ON
                    p3.center = s3.OWNER_CENTER
                    AND p3.id = s3.OWNER_ID
                WHERE
                    p3.CURRENT_PERSON_CENTER = p.CENTER
                    AND p3.CURRENT_PERSON_ID = p.id
                    AND s3.START_DATE < s.START_DATE )
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
WHERE
    p.center IN ($$scope$$)
    -- and p.id = 298
    AND NOT EXISTS
    (
        SELECT
            1
        FROM
            PUREGYM.SUBSCRIPTIONS s2
        JOIN
            PUREGYM.SUBSCRIPTIONTYPES st2
        ON
            st2.CENTER = s2.SUBSCRIPTIONTYPE_CENTER
            AND st2.id = s2.SUBSCRIPTIONTYPE_ID
            AND (ST2.CENTER, ST2.ID) not in (select center, id from V_EXCLUDED_SUBSCRIPTIONS) 
        JOIN
            PUREGYM.PERSONS p3
        ON
            p3.center = s2.OWNER_CENTER
            AND p3.id = s2.OWNER_ID
        WHERE
            p3.CURRENT_PERSON_CENTER = p.CENTER
            AND p3.CURRENT_PERSON_ID = p.id
            AND s2.START_DATE < s.START_DATE )