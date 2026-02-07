SELECT
    p_external          AS "Enternal ID",
    p_FULLNAME          AS "Full Name",
    p_SEX               AS "Sex",
    p_BIRTHDATE         AS "Birthdate",
    p_CENTER||'p'||p_ID AS "MemberID",
    --s_center,
    --s_id,
    MAX(class1_ID)          AS "Class 1 ID",
    MAX(class1_Date)        AS "Class 1 Date",
    MAX(class1_time)        AS "Class 1 time",
    MAX(class1_Instructor)  AS "Class 1 Instructor",
    MAX(class1_Visit)       AS "Class 1 Visit",
    MAX(class1_Showup)      AS "Class 1 Showupme",
    MAX(class1_Active)      AS "Class 1 Active",
    MAX(class2_ID)          AS "Class 2 ID",
    MAX(class2_Date)        AS "Class 2 Date",
    MAX(class2_time)        AS "Class 2 time",
    MAX(class2_Instructor)  AS "Class 2 Instructor",
    MAX(class2_Visit)       AS "Class 2 Visit",
    MAX(class2_Showup)      AS "Class 2 Showup",
    MAX(class2_Active)      AS "Class 2 Active",
    MAX(class3_ID)          AS "Class 3 ID",
    MAX(class3_Date)        AS "Class 3 Date",
    MAX(class3_time)        AS "Class 3 time",
    MAX(class3_Instructor)  AS "Class 3 Instructor",
    MAX(class3_Visit)       AS "Class 3 Visit",
    MAX(class3_Showup)      AS "Class 3 Showup",
    MAX(class3_Active)      AS "Class 3 Active",
    MAX(class4_ID)          AS "Class 4 ID",
    MAX(class4_Date)        AS "Class 4 Date",
    MAX(class4_time)        AS "Class 4 time",
    MAX(class4_Instructor)  AS "Class 4 Instructor",
    MAX(class4_Visit)       AS "Class 4 Visit",
    MAX(class4_Showup)      AS "Class 4 Showup",
    MAX(class4_Active)      AS "Class 4 Active",
    MAX(class5_ID)          AS "Class 5 ID",
    MAX(class5_Date)        AS "Class 5 Date",
    MAX(class5_time)        AS "Class 5 time",
    MAX(class5_Instructor)  AS "Class 5 Instructor",
    MAX(class5_Visit)       AS "Class 5 Visit",
    MAX(class5_Showup)      AS "Class 5 Showup",
    MAX(class5_Active)      AS "Class 5 Active",
    MAX(class6_ID)          AS "Class 6 ID",
    MAX(class6_Date)        AS "Class 6 Date",
    MAX(class6_time)        AS "Class 6 time",
    MAX(class6_Instructor)  AS "Class 6 Instructor",
    MAX(class6_Visit)       AS "Class 6 Visit",
    MAX(class6_Showup)      AS "Class 6 Showup",
    MAX(class7_ID)          AS "Class 7 ID",
    MAX(class7_Active)      AS "Class 7 Active",
    MAX(class7_time)        AS "Class 7 time",
    MAX(class7_Instructor)  AS "Class 7 Instructor",
    MAX(class7_Visit)       AS "Class 7 Visit",
    MAX(class7_Showup)      AS "Class 7 Showup",
    MAX(class8_ID)          AS "Class 8 ID",
    MAX(class8_Active)      AS "Class 8 Active",
    MAX(class8_time)        AS "Class 8 time",
    MAX(class8_Instructor)  AS "Class 8 Instructor",
    MAX(class8_Visit)       AS "Class 8 Visit",
    MAX(class8_Showup)      AS "Class 8 Showup",
    MAX(class9_ID)          AS "Class 9 ID",
    MAX(class9_Active)      AS "Class 9 Active",
    MAX(class9_time)        AS "Class 9 time",
    MAX(class9_Instructor)  AS "Class 9 Instructor",
    MAX(class9_Visit)       AS "Class 9 Visit",
    MAX(class9_Showup)      AS "Class 9 Showup",
    MAX(class10_ID)         AS "Class 10 ID",
    MAX(class10_Active)     AS "Class 10 Active",
    MAX(class10_time)       AS "Class 10 time",
    MAX(class10_Instructor) AS "Class 10 Instructor",
    MAX(class10_Visit)      AS "Class 10 Visit",
    MAX(class10_Showup)     AS "Class 10 Showup",
    MAX(class11_ID)         AS "Class 11 ID",
    MAX(class11_Active)     AS "Class 11 Active",
    MAX(class11_time)       AS "Class 11 time",
    MAX(class11_Instructor) AS "Class 11 Instructor",
    MAX(class11_Visit)      AS "Class 11 Visit",
    MAX(class11_Showup)     AS "Class 11 Showup",
    MAX(class12_ID)         AS "Class 12 ID",
    MAX(class12_Active)     AS "Class 12 Active",
    MAX(class12_time)       AS "Class 12 time",
    MAX(class12_Instructor) AS "Class 12 Instructor",
    MAX(class12_Visit)      AS "Class 12 Visit",
    MAX(class12_Showup)     AS "Class 12 Showup"
FROM
    (
        SELECT
            cp.EXTERNAL_ID                                                                                                                                                  p_external,
            s.center                                                                                                                                                        s_center,
            s.id                                                                                                                                                            s_id,
            pa.PARTICIPANT_CENTER                                                                                                                                           p_center,
            pa.PARTICIPANT_ID                                                                                                                                               p_ID,
            p.BIRTHDATE                                                                                                                                                     p_BIRTHDATE,
            p.FULLNAME                                                                                                                                                      p_FULLNAME,
            p.SEX                                                                                                                                                           p_SEX,
            DECODE(COUNT(bo.center||'book'||bo.id) over (PARTITION BY s.center||'ss'||s.id ORDER BY bo.STARTTIME),1, bo.center||'book'||bo.id,NULL)                         class1_ID,
            DECODE(COUNT(bo.center||'book'||bo.id) over (PARTITION BY s.center||'ss'||s.id ORDER BY bo.STARTTIME),1, TO_CHAR(longtodate(bo.STARTTIME), 'yyyy-MM-dd'),NULL)  class1_Date,
            DECODE(COUNT(bo.center||'book'||bo.id) over (PARTITION BY s.center||'ss'||s.id ORDER BY bo.STARTTIME),1, TO_CHAR(longtodate(bo.STARTTIME), 'HH24:MI'),NULL)     class1_time,
            DECODE(COUNT(bo.center||'book'||bo.id) over (PARTITION BY s.center||'ss'||s.id ORDER BY bo.STARTTIME),1, ins.FULLNAME,NULL)                                     class1_Instructor,
            DECODE(COUNT(bo.center||'book'||bo.id) over (PARTITION BY s.center||'ss'||s.id ORDER BY bo.STARTTIME),1, longtodate(pa.START_TIME),NULL)                        class1_Visit,
            DECODE(COUNT(bo.center||'book'||bo.id) over (PARTITION BY s.center||'ss'||s.id ORDER BY bo.STARTTIME),1, DECODE(pa.STATE,'PARTICIPATION','yes','no'),NULL)      class1_Showup,
            DECODE(COUNT(bo.center||'book'||bo.id) over (PARTITION BY s.center||'ss'||s.id ORDER BY bo.STARTTIME),1, DECODE(bo.STATE,'ACTIVE','yes','no'),NULL)             class1_Active,
            DECODE(COUNT(bo.center||'book'||bo.id) over (PARTITION BY s.center||'ss'||s.id ORDER BY bo.STARTTIME),2, bo.center||'book'||bo.id,NULL)                         class2_ID,
            DECODE(COUNT(bo.center||'book'||bo.id) over (PARTITION BY s.center||'ss'||s.id ORDER BY bo.STARTTIME),2, TO_CHAR(longtodate(bo.STARTTIME), 'yyyy-MM-dd'),NULL)  class2_Date,
            DECODE(COUNT(bo.center||'book'||bo.id) over (PARTITION BY s.center||'ss'||s.id ORDER BY bo.STARTTIME),2, TO_CHAR(longtodate(bo.STARTTIME), 'HH24:MI'),NULL)     class2_time,
            DECODE(COUNT(bo.center||'book'||bo.id) over (PARTITION BY s.center||'ss'||s.id ORDER BY bo.STARTTIME),2, ins.FULLNAME,NULL)                                     class2_Instructor,
            DECODE(COUNT(bo.center||'book'||bo.id) over (PARTITION BY s.center||'ss'||s.id ORDER BY bo.STARTTIME),2, longtodate(pa.START_TIME),NULL)                        class2_Visit,
            DECODE(COUNT(bo.center||'book'||bo.id) over (PARTITION BY s.center||'ss'||s.id ORDER BY bo.STARTTIME),2, DECODE(pa.STATE,'PARTICIPATION','yes','no'),NULL)      class2_Showup,
            DECODE(COUNT(bo.center||'book'||bo.id) over (PARTITION BY s.center||'ss'||s.id ORDER BY bo.STARTTIME),2, DECODE(bo.STATE,'ACTIVE','yes','no'),NULL)             class2_Active,
            DECODE(COUNT(bo.center||'book'||bo.id) over (PARTITION BY s.center||'ss'||s.id ORDER BY bo.STARTTIME),3, bo.center||'book'||bo.id,NULL)                         class3_ID,
            DECODE(COUNT(bo.center||'book'||bo.id) over (PARTITION BY s.center||'ss'||s.id ORDER BY bo.STARTTIME),3, TO_CHAR(longtodate(bo.STARTTIME), 'yyyy-MM-dd'),NULL)  class3_Date,
            DECODE(COUNT(bo.center||'book'||bo.id) over (PARTITION BY s.center||'ss'||s.id ORDER BY bo.STARTTIME),3, TO_CHAR(longtodate(bo.STARTTIME), 'HH24:MI'),NULL)     class3_time,
            DECODE(COUNT(bo.center||'book'||bo.id) over (PARTITION BY s.center||'ss'||s.id ORDER BY bo.STARTTIME),3, ins.FULLNAME,NULL)                                     class3_Instructor,
            DECODE(COUNT(bo.center||'book'||bo.id) over (PARTITION BY s.center||'ss'||s.id ORDER BY bo.STARTTIME),3, longtodate(pa.START_TIME),NULL)                        class3_Visit,
            DECODE(COUNT(bo.center||'book'||bo.id) over (PARTITION BY s.center||'ss'||s.id ORDER BY bo.STARTTIME),3, DECODE(pa.STATE,'PARTICIPATION','yes','no'),NULL)      class3_Showup,
            DECODE(COUNT(bo.center||'book'||bo.id) over (PARTITION BY s.center||'ss'||s.id ORDER BY bo.STARTTIME),3, DECODE(bo.STATE,'ACTIVE','yes','no'),NULL)             class3_Active,
            DECODE(COUNT(bo.center||'book'||bo.id) over (PARTITION BY s.center||'ss'||s.id ORDER BY bo.STARTTIME),4, bo.center||'book'||bo.id,NULL)                         class4_ID,
            DECODE(COUNT(bo.center||'book'||bo.id) over (PARTITION BY s.center||'ss'||s.id ORDER BY bo.STARTTIME),4, TO_CHAR(longtodate(bo.STARTTIME), 'yyyy-MM-dd'),NULL)  class4_Date,
            DECODE(COUNT(bo.center||'book'||bo.id) over (PARTITION BY s.center||'ss'||s.id ORDER BY bo.STARTTIME),4, TO_CHAR(longtodate(bo.STARTTIME), 'HH24:MI'),NULL)     class4_time,
            DECODE(COUNT(bo.center||'book'||bo.id) over (PARTITION BY s.center||'ss'||s.id ORDER BY bo.STARTTIME),4, ins.FULLNAME,NULL)                                     class4_Instructor,
            DECODE(COUNT(bo.center||'book'||bo.id) over (PARTITION BY s.center||'ss'||s.id ORDER BY bo.STARTTIME),4, longtodate(pa.START_TIME),NULL)                        class4_Visit,
            DECODE(COUNT(bo.center||'book'||bo.id) over (PARTITION BY s.center||'ss'||s.id ORDER BY bo.STARTTIME),4, DECODE(pa.STATE,'PARTICIPATION','yes','no'),NULL)      class4_Showup,
            DECODE(COUNT(bo.center||'book'||bo.id) over (PARTITION BY s.center||'ss'||s.id ORDER BY bo.STARTTIME),4, DECODE(bo.STATE,'ACTIVE','yes','no'),NULL)             class4_Active,
            DECODE(COUNT(bo.center||'book'||bo.id) over (PARTITION BY s.center||'ss'||s.id ORDER BY bo.STARTTIME),5, bo.center||'book'||bo.id,NULL)                         class5_ID,
            DECODE(COUNT(bo.center||'book'||bo.id) over (PARTITION BY s.center||'ss'||s.id ORDER BY bo.STARTTIME),5, TO_CHAR(longtodate(bo.STARTTIME), 'yyyy-MM-dd'),NULL)  class5_Date,
            DECODE(COUNT(bo.center||'book'||bo.id) over (PARTITION BY s.center||'ss'||s.id ORDER BY bo.STARTTIME),5, TO_CHAR(longtodate(bo.STARTTIME), 'HH24:MI'),NULL)     class5_time,
            DECODE(COUNT(bo.center||'book'||bo.id) over (PARTITION BY s.center||'ss'||s.id ORDER BY bo.STARTTIME),5, ins.FULLNAME,NULL)                                     class5_Instructor,
            DECODE(COUNT(bo.center||'book'||bo.id) over (PARTITION BY s.center||'ss'||s.id ORDER BY bo.STARTTIME),5, longtodate(pa.START_TIME),NULL)                        class5_Visit,
            DECODE(COUNT(bo.center||'book'||bo.id) over (PARTITION BY s.center||'ss'||s.id ORDER BY bo.STARTTIME),5, DECODE(pa.STATE,'PARTICIPATION','yes','no'),NULL)      class5_Showup,
            DECODE(COUNT(bo.center||'book'||bo.id) over (PARTITION BY s.center||'ss'||s.id ORDER BY bo.STARTTIME),5, DECODE(bo.STATE,'ACTIVE','yes','no'),NULL)             class5_Active,
            DECODE(COUNT(bo.center||'book'||bo.id) over (PARTITION BY s.center||'ss'||s.id ORDER BY bo.STARTTIME),6, bo.center||'book'||bo.id,NULL)                         class6_ID,
            DECODE(COUNT(bo.center||'book'||bo.id) over (PARTITION BY s.center||'ss'||s.id ORDER BY bo.STARTTIME),6, TO_CHAR(longtodate(bo.STARTTIME), 'yyyy-MM-dd'),NULL)  class6_Date,
            DECODE(COUNT(bo.center||'book'||bo.id) over (PARTITION BY s.center||'ss'||s.id ORDER BY bo.STARTTIME),6, TO_CHAR(longtodate(bo.STARTTIME), 'HH24:MI'),NULL)     class6_time,
            DECODE(COUNT(bo.center||'book'||bo.id) over (PARTITION BY s.center||'ss'||s.id ORDER BY bo.STARTTIME),6, ins.FULLNAME,NULL)                                     class6_Instructor,
            DECODE(COUNT(bo.center||'book'||bo.id) over (PARTITION BY s.center||'ss'||s.id ORDER BY bo.STARTTIME),6, longtodate(pa.START_TIME),NULL)                        class6_Visit,
            DECODE(COUNT(bo.center||'book'||bo.id) over (PARTITION BY s.center||'ss'||s.id ORDER BY bo.STARTTIME),6, DECODE(pa.STATE,'PARTICIPATION','yes','no'),NULL)      class6_Showup,
            DECODE(COUNT(bo.center||'book'||bo.id) over (PARTITION BY s.center||'ss'||s.id ORDER BY bo.STARTTIME),6, DECODE(bo.STATE,'ACTIVE','yes','no'),NULL)             class6_Active,
            DECODE(COUNT(bo.center||'book'||bo.id) over (PARTITION BY s.center||'ss'||s.id ORDER BY bo.STARTTIME),7, bo.center||'book'||bo.id,NULL)                         class7_ID,
            DECODE(COUNT(bo.center||'book'||bo.id) over (PARTITION BY s.center||'ss'||s.id ORDER BY bo.STARTTIME),7, TO_CHAR(longtodate(bo.STARTTIME), 'yyyy-MM-dd'),NULL)  class7_Date,
            DECODE(COUNT(bo.center||'book'||bo.id) over (PARTITION BY s.center||'ss'||s.id ORDER BY bo.STARTTIME),7, TO_CHAR(longtodate(bo.STARTTIME), 'HH24:MI'),NULL)     class7_time,
            DECODE(COUNT(bo.center||'book'||bo.id) over (PARTITION BY s.center||'ss'||s.id ORDER BY bo.STARTTIME),7, ins.FULLNAME,NULL)                                     class7_Instructor,
            DECODE(COUNT(bo.center||'book'||bo.id) over (PARTITION BY s.center||'ss'||s.id ORDER BY bo.STARTTIME),7, longtodate(pa.START_TIME),NULL)                        class7_Visit,
            DECODE(COUNT(bo.center||'book'||bo.id) over (PARTITION BY s.center||'ss'||s.id ORDER BY bo.STARTTIME),7, DECODE(pa.STATE,'PARTICIPATION','yes','no'),NULL)      class7_Showup,
            DECODE(COUNT(bo.center||'book'||bo.id) over (PARTITION BY s.center||'ss'||s.id ORDER BY bo.STARTTIME),7, DECODE(bo.STATE,'ACTIVE','yes','no'),NULL)             class7_Active,
            DECODE(COUNT(bo.center||'book'||bo.id) over (PARTITION BY s.center||'ss'||s.id ORDER BY bo.STARTTIME),8, bo.center||'book'||bo.id,NULL)                         class8_ID,
            DECODE(COUNT(bo.center||'book'||bo.id) over (PARTITION BY s.center||'ss'||s.id ORDER BY bo.STARTTIME),8, TO_CHAR(longtodate(bo.STARTTIME), 'yyyy-MM-dd'),NULL)  class8_Date,
            DECODE(COUNT(bo.center||'book'||bo.id) over (PARTITION BY s.center||'ss'||s.id ORDER BY bo.STARTTIME),8, TO_CHAR(longtodate(bo.STARTTIME), 'HH24:MI'),NULL)     class8_time,
            DECODE(COUNT(bo.center||'book'||bo.id) over (PARTITION BY s.center||'ss'||s.id ORDER BY bo.STARTTIME),8, ins.FULLNAME,NULL)                                     class8_Instructor,
            DECODE(COUNT(bo.center||'book'||bo.id) over (PARTITION BY s.center||'ss'||s.id ORDER BY bo.STARTTIME),8, longtodate(pa.START_TIME),NULL)                        class8_Visit,
            DECODE(COUNT(bo.center||'book'||bo.id) over (PARTITION BY s.center||'ss'||s.id ORDER BY bo.STARTTIME),8, DECODE(pa.STATE,'PARTICIPATION','yes','no'),NULL)      class8_Showup,
            DECODE(COUNT(bo.center||'book'||bo.id) over (PARTITION BY s.center||'ss'||s.id ORDER BY bo.STARTTIME),8, DECODE(bo.STATE,'ACTIVE','yes','no'),NULL)             class8_Active,
            DECODE(COUNT(bo.center||'book'||bo.id) over (PARTITION BY s.center||'ss'||s.id ORDER BY bo.STARTTIME),9, bo.center||'book'||bo.id,NULL)                         class9_ID,
            DECODE(COUNT(bo.center||'book'||bo.id) over (PARTITION BY s.center||'ss'||s.id ORDER BY bo.STARTTIME),9, TO_CHAR(longtodate(bo.STARTTIME), 'yyyy-MM-dd'),NULL)  class9_Date,
            DECODE(COUNT(bo.center||'book'||bo.id) over (PARTITION BY s.center||'ss'||s.id ORDER BY bo.STARTTIME),9, TO_CHAR(longtodate(bo.STARTTIME), 'HH24:MI'),NULL)     class9_time,
            DECODE(COUNT(bo.center||'book'||bo.id) over (PARTITION BY s.center||'ss'||s.id ORDER BY bo.STARTTIME),9, ins.FULLNAME,NULL)                                     class9_Instructor,
            DECODE(COUNT(bo.center||'book'||bo.id) over (PARTITION BY s.center||'ss'||s.id ORDER BY bo.STARTTIME),9, longtodate(pa.START_TIME),NULL)                        class9_Visit,
            DECODE(COUNT(bo.center||'book'||bo.id) over (PARTITION BY s.center||'ss'||s.id ORDER BY bo.STARTTIME),9, DECODE(pa.STATE,'PARTICIPATION','yes','no'),NULL)      class9_Showup,
            DECODE(COUNT(bo.center||'book'||bo.id) over (PARTITION BY s.center||'ss'||s.id ORDER BY bo.STARTTIME),9, DECODE(bo.STATE,'ACTIVE','yes','no'),NULL)             class9_Active,
            DECODE(COUNT(bo.center||'book'||bo.id) over (PARTITION BY s.center||'ss'||s.id ORDER BY bo.STARTTIME),10, bo.center||'book'||bo.id,NULL)                        class10_ID,
            DECODE(COUNT(bo.center||'book'||bo.id) over (PARTITION BY s.center||'ss'||s.id ORDER BY bo.STARTTIME),10, TO_CHAR(longtodate(bo.STARTTIME), 'yyyy-MM-dd'),NULL) class10_Date,
            DECODE(COUNT(bo.center||'book'||bo.id) over (PARTITION BY s.center||'ss'||s.id ORDER BY bo.STARTTIME),10, TO_CHAR(longtodate(bo.STARTTIME), 'HH24:MI'),NULL)    class10_time,
            DECODE(COUNT(bo.center||'book'||bo.id) over (PARTITION BY s.center||'ss'||s.id ORDER BY bo.STARTTIME),10, ins.FULLNAME,NULL)                                    class10_Instructor,
            DECODE(COUNT(bo.center||'book'||bo.id) over (PARTITION BY s.center||'ss'||s.id ORDER BY bo.STARTTIME),10, longtodate(pa.START_TIME),NULL)                       class10_Visit,
            DECODE(COUNT(bo.center||'book'||bo.id) over (PARTITION BY s.center||'ss'||s.id ORDER BY bo.STARTTIME),10, DECODE(pa.STATE,'PARTICIPATION','yes','no'),NULL)     class10_Showup,
            DECODE(COUNT(bo.center||'book'||bo.id) over (PARTITION BY s.center||'ss'||s.id ORDER BY bo.STARTTIME),10, DECODE(bo.STATE,'ACTIVE','yes','no'),NULL)            class10_Active,
            DECODE(COUNT(bo.center||'book'||bo.id) over (PARTITION BY s.center||'ss'||s.id ORDER BY bo.STARTTIME),11, bo.center||'book'||bo.id,NULL)                        class11_ID,
            DECODE(COUNT(bo.center||'book'||bo.id) over (PARTITION BY s.center||'ss'||s.id ORDER BY bo.STARTTIME),11, TO_CHAR(longtodate(bo.STARTTIME), 'yyyy-MM-dd'),NULL) class11_Date,
            DECODE(COUNT(bo.center||'book'||bo.id) over (PARTITION BY s.center||'ss'||s.id ORDER BY bo.STARTTIME),11, TO_CHAR(longtodate(bo.STARTTIME), 'HH24:MI'),NULL)    class11_time,
            DECODE(COUNT(bo.center||'book'||bo.id) over (PARTITION BY s.center||'ss'||s.id ORDER BY bo.STARTTIME),11, ins.FULLNAME,NULL)                                    class11_Instructor,
            DECODE(COUNT(bo.center||'book'||bo.id) over (PARTITION BY s.center||'ss'||s.id ORDER BY bo.STARTTIME),11, longtodate(pa.START_TIME),NULL)                       class11_Visit,
            DECODE(COUNT(bo.center||'book'||bo.id) over (PARTITION BY s.center||'ss'||s.id ORDER BY bo.STARTTIME),11, DECODE(pa.STATE,'PARTICIPATION','yes','no'),NULL)     class11_Showup,
            DECODE(COUNT(bo.center||'book'||bo.id) over (PARTITION BY s.center||'ss'||s.id ORDER BY bo.STARTTIME),11, DECODE(bo.STATE,'ACTIVE','yes','no'),NULL)            class11_Active,
            DECODE(COUNT(bo.center||'book'||bo.id) over (PARTITION BY s.center||'ss'||s.id ORDER BY bo.STARTTIME),12, bo.center||'book'||bo.id,NULL)                        class12_ID,
            DECODE(COUNT(bo.center||'book'||bo.id) over (PARTITION BY s.center||'ss'||s.id ORDER BY bo.STARTTIME),12, TO_CHAR(longtodate(bo.STARTTIME), 'yyyy-MM-dd'),NULL) class12_Date,
            DECODE(COUNT(bo.center||'book'||bo.id) over (PARTITION BY s.center||'ss'||s.id ORDER BY bo.STARTTIME),12, TO_CHAR(longtodate(bo.STARTTIME), 'HH24:MI'),NULL)    class12_time,
            DECODE(COUNT(bo.center||'book'||bo.id) over (PARTITION BY s.center||'ss'||s.id ORDER BY bo.STARTTIME),12, ins.FULLNAME,NULL)                                    class12_Instructor,
            DECODE(COUNT(bo.center||'book'||bo.id) over (PARTITION BY s.center||'ss'||s.id ORDER BY bo.STARTTIME),12, longtodate(pa.START_TIME),NULL)                       class12_Visit,
            DECODE(COUNT(bo.center||'book'||bo.id) over (PARTITION BY s.center||'ss'||s.id ORDER BY bo.STARTTIME),12, DECODE(pa.STATE,'PARTICIPATION','yes','no'),NULL)     class12_Showup,
            DECODE(COUNT(bo.center||'book'||bo.id) over (PARTITION BY s.center||'ss'||s.id ORDER BY bo.STARTTIME),12, DECODE(bo.STATE,'ACTIVE','yes','no'),NULL)            class12_Active
        FROM
            PUREGYM.SUBSCRIPTIONS s
        JOIN
            PUREGYM.PRODUCTS pr
        ON
            pr.center = s.SUBSCRIPTIONTYPE_CENTER
            AND pr.id = s.SUBSCRIPTIONTYPE_ID
            AND pr.GLOBALID = 'PURE_LOSER'
        JOIN
            PUREGYM.PARTICIPATIONS pa
        ON
            pa.PARTICIPANT_CENTER = s.OWNER_CENTER
            AND pa.PARTICIPANT_ID = s.OWNER_ID
            AND (
                pa.CANCELATION_REASON IS NULL
                OR pa.CANCELATION_REASON IN ( 'NO_SHOW'))
            AND longtodate(pa.START_TIME) BETWEEN s.START_DATE AND s.END_DATE --Only classes within the time frame of the subscription
        JOIN
            PUREGYM.BOOKINGS bo
        ON
            bo.CENTER = pa.BOOKING_CENTER
            AND bo.id = pa.BOOKING_ID
            AND bo.ACTIVITY = 401 --Only Pure Loser
        LEFT JOIN
            PUREGYM.STAFF_USAGE su
        ON
            su.BOOKING_CENTER = bo.CENTER
            AND su.BOOKING_ID = bo.ID
        LEFT JOIN
            PUREGYM.PERSONS p
        ON
            p.CENTER = s.OWNER_CENTER
            AND p.id = s.OWNER_ID
        LEFT JOIN
            PUREGYM.PERSONS cp
        ON
            p.CURRENT_PERSON_CENTER = cp.CENTER
            AND p.CURRENT_PERSON_ID = cp.ID
        LEFT JOIN
            PUREGYM.BOOKING_RESOURCE_USAGE bru
        ON
            bru.BOOKING_CENTER = bo.CENTER
            AND bru.BOOKING_ID = bo.ID
        LEFT JOIN
            PUREGYM.PERSONS ins
        ON
            ins.CENTER = su.PERSON_CENTER
            AND ins.id = su.PERSON_ID
            /*WHERE
            s.OWNER_CENTER =184
            AND s.OWNER_ID= 4648*/
        ORDER BY
            s.CENTER,
            s.id,
            bo.STARTTIME)
    /*WHERE
    class8_Active IS NOT NULL*/
GROUP BY
    p_external,
    s_center,
    s_id,
    p_CENTER ,
    p_ID ,
    p_BIRTHDATE ,
    p_FULLNAME ,
    p_SEX
ORDER BY
    s_center,
    s_id