-- The extract is extracted from Exerp on 2026-02-08
--  
SELECT
    *
FROM
    (
        SELECT
            c.name                           AS "Club NAme",
            a.name                           AS "Regional Manager",
            p.CENTER||'p'||p.id              AS "Pref",
            TO_CHAR(s.END_DATE,'yyyy-MM-dd') AS "Sub End Date",
            'Week '||TO_CHAR(TRUNC((TRUNC(s.END_DATE) - TRUNC(longtodatetz(ch.CHECKIN_TIME,'Europe/London')))/7)+1) "Week",
            ch.id AS                                                                                                "chkins"
        FROM
            PUREGYM.SUBSCRIPTIONS s
        JOIN
            PUREGYM.SUBSCRIPTIONTYPES st
        ON
            st.CENTER = s.SUBSCRIPTIONTYPE_CENTER
            AND st.id = s.SUBSCRIPTIONTYPE_ID
            AND st.ST_TYPE = 1
        JOIN
            PUREGYM.PERSONS p
        ON
            p.CENTER = s.OWNER_CENTER
            AND p.id = s.OWNER_ID
            AND p.CURRENT_PERSON_CENTER IN ($$scope$$)
        JOIN
            PUREGYM.PERSONS p2
        ON
            p2.CURRENT_PERSON_CENTER = p.CURRENT_PERSON_CENTER
            AND p.CURRENT_PERSON_ID = p2.CURRENT_PERSON_ID
        LEFT JOIN
            PUREGYM.SUBSCRIPTIONS s2
        ON
            s2.OWNER_CENTER = p.CURRENT_PERSON_CENTER
            AND s2.OWNER_ID = p.CURRENT_PERSON_ID
            AND (
                s2.END_DATE > s.END_DATE
                OR s2.END_DATE IS NULL)
            AND (
                s2.END_DATE >s2.START_DATE
                OR s2.END_DATE IS NULL)
        LEFT JOIN
            PUREGYM.CHECKINS ch
        ON
            ch.PERSON_CENTER = p2.CENTER
            AND ch.PERSON_ID = p2.ID
            AND ch.CHECKIN_TIME >= datetolong(TO_CHAR(add_months($$to_date$$,-12)+2, 'YYYY-MM-dd HH24:MI'))
        LEFT JOIN
            PUREGYM.CHECKINS ch2
        ON
            ch2.PERSON_CENTER = p2.CENTER
            AND ch2.PERSON_ID = p2.ID
            AND ch2.CHECKIN_TIME BETWEEN ch.CHECKIN_TIME +1 AND ch.CHECKIN_TIME + 1000*60*60*2
        JOIN
            PUREGYM.CENTERS c
        ON
            c.id = p.CENTER
        JOIN
            AREA_CENTERS AC
        ON
            c.ID = AC.CENTER
        JOIN
            AREAS A
        ON
            A.ID = AC.AREA
            AND A.PARENT = 61
        WHERE
            s2.CENTER IS NULL
            --and p.id =2505
            AND ch2.id IS NULL
            AND s.END_DATE BETWEEN $$from_date$$ AND $$to_date$$ ) pivot (COUNT ("chkins") FOR "Week" IN ('Week 1' AS "Week 01",
                                                                                                      'Week 2' AS "Week 02",
                                                                                                      'Week 3' AS "Week 03",
                                                                                                      'Week 4' AS "Week 04",
                                                                                                      'Week 5' AS "Week 05",
                                                                                                      'Week 6' AS "Week 06",
                                                                                                      'Week 7' AS "Week 07",
                                                                                                      'Week 8' AS "Week 08",
                                                                                                      'Week 9' AS "Week 09",
                                                                                                      'Week 10' AS "Week 10",
                                                                                                      'Week 11' AS "Week 11",
                                                                                                      'Week 12' AS "Week 12",
                                                                                                      'Week 13' AS "Week 13",
                                                                                                      'Week 14' AS "Week 14",
                                                                                                      'Week 15' AS "Week 15",
                                                                                                      'Week 16' AS "Week 16",
                                                                                                      'Week 17' AS "Week 17",
                                                                                                      'Week 18' AS "Week 18",
                                                                                                      'Week 19' AS "Week 19",
                                                                                                      'Week 20' AS "Week 20",
                                                                                                      'Week 21' AS "Week 21",
                                                                                                      'Week 22' AS "Week 22",
                                                                                                      'Week 23' AS "Week 23",
                                                                                                      'Week 24' AS "Week 24",
                                                                                                      'Week 25' AS "Week 25",
                                                                                                      'Week 26' AS "Week 26",
                                                                                                      'Week 27' AS "Week 27",
                                                                                                      'Week 28' AS "Week 28",
                                                                                                      'Week 29' AS "Week 29",
                                                                                                      'Week 30' AS "Week 30",
                                                                                                      'Week 31' AS "Week 31",
                                                                                                      'Week 32' AS "Week 32",
                                                                                                      'Week 33' AS "Week 33",
                                                                                                      'Week 34' AS "Week 34",
                                                                                                      'Week 35' AS "Week 35",
                                                                                                      'Week 36' AS "Week 36",
                                                                                                      'Week 37' AS "Week 37",
                                                                                                      'Week 38' AS "Week 38",
                                                                                                      'Week 39' AS "Week 39",
                                                                                                      'Week 40' AS "Week 40",
                                                                                                      'Week 41' AS "Week 41",
                                                                                                      'Week 42' AS "Week 42",
                                                                                                      'Week 43' AS "Week 43",
                                                                                                      'Week 44' AS "Week 44",
                                                                                                      'Week 45' AS "Week 45",
                                                                                                      'Week 46' AS "Week 46",
                                                                                                      'Week 47' AS "Week 47",
                                                                                                      'Week 48' AS "Week 48",
                                                                                                      'Week 49' AS "Week 49",
                                                                                                      'Week 50' AS "Week 50",
                                                                                                      'Week 51' AS "Week 51",
                                                                                                      'Week 52' AS "Week 52" ))