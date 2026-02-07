SELECT
    /*+ NO_BIND_AWARE */
    -- count joiners / leavers by region
    a.center ClubNumber,
    c.NAME    AS "Center Name",
    c.ZIPCODE AS "Center Post Code",
    a.ZIPCODE,
    a.joiners,
    a.leavers,
    a.Rejoiner,
    a.Trans_from,
    a.Trans_to,
    a.Region,
    SUM(a.joiners) over (partition BY a.Region)    AS "Joiners RPC",
    SUM(a.leavers) over (partition BY a.Region)    AS "leavers RPC",
    SUM(a.Rejoiner) over (partition BY a.Region)   AS "Rejoiner RPC",
    SUM(a.Trans_from) over (partition BY a.Region) AS "Trans_from RPC",
    SUM(a.Trans_to) over (partition BY a.Region)   AS "Trans_to RPC"
FROM
    (
        SELECT
            center,
            ZIPCODE,
            CASE
                WHEN SUBSTR(SUBSTR(ZIPCODE,0,LENGTH(ZIPCODE)-3),-1,1)=' '
                THEN SUBSTR(SUBSTR(ZIPCODE,0,LENGTH(ZIPCODE)-3),0,LENGTH(SUBSTR(ZIPCODE,0,LENGTH(ZIPCODE)-3))-1)
                ELSE SUBSTR(ZIPCODE,0,LENGTH(ZIPCODE)-3)
            END Region ,
            SUM(
                CASE
                    WHEN ended = 1
                        AND not_leaver = 0
                    THEN 1
                END )AS leavers,
            SUM(
                CASE
                    WHEN ended = 1
                        AND trans_from = 1
                    THEN 1
                END) AS trans_from,
            SUM(
                CASE
                    WHEN started = 1
                        AND not_joiner = 0
                        AND trans_to=0
                    THEN 1
                END) AS joiners,
            SUM(
                CASE
                    WHEN started = 1
                        AND trans_to = 1
                    THEN 1
                END) AS trans_to,
            SUM(
                CASE
                    WHEN is_rejoin = 1
                    THEN 1
                END) AS rejoiner
        FROM
            (
                SELECT DISTINCT
                    p.CENTER,
                    p.ID,
                    p.ZIPCODE,
                    MAX(
                        CASE
                            WHEN s.END_DATE BETWEEN TRUNC(SYSDATE,'MM') AND TRUNC(SYSDATE) --ended
                            THEN 1
                            ELSE 0
                        END) AS ended,
                    MAX(
                        CASE
                            WHEN s.CREATION_TIME BETWEEN dateToLong(TO_CHAR( TRUNC(SYSDATE,'MM'), 'YYYY-MM-dd HH24:MI')) AND dateToLong(TO_CHAR( TRUNC(SYSDATE), 'YYYY-MM-dd HH24:MI')) --started
                            THEN 1
                            ELSE 0
                        END) AS started,
                    MAX(
                        CASE
                            WHEN s.END_DATE BETWEEN TRUNC(SYSDATE,'MM') AND TRUNC(SYSDATE) --ended
                                AND s2.CREATION_TIME BETWEEN dateToLong(TO_CHAR( TRUNC(SYSDATE,'MM'), 'YYYY-MM-dd HH24:MI')) AND dateToLong(TO_CHAR( TRUNC(SYSDATE), 'YYYY-MM-dd HH24:MI'))--other sub active on other member, meaning trans_from
                                AND s2.OWNER_CENTER !=s.OWNER_CENTER
                            THEN 1
                            ELSE 0
                        END) AS trans_from,
                    SUM( --if 0 then no other subscriptions starting later, meaning leaver
                        CASE
                            WHEN s.END_DATE BETWEEN TRUNC(SYSDATE,'MM') AND TRUNC(SYSDATE) --ended
                                AND (s2.START_DATE > =s.END_DATE
                                    OR s2.STATE IN (2,4))
                            THEN 1
                            ELSE 0
                        END) AS not_leaver,
                    SUM( --if 0 then no other subscriptions starting earlier, meaning joiner
                        CASE
                            WHEN s.CREATION_TIME BETWEEN dateToLong(TO_CHAR( TRUNC(SYSDATE,'MM'), 'YYYY-MM-dd HH24:MI')) AND dateToLong(TO_CHAR( TRUNC(SYSDATE), 'YYYY-MM-dd HH24:MI')) --started,
                                AND s2.START_DATE<s.START_DATE --not first subscription,
                            THEN 1
                            ELSE 0
                        END) AS not_joiner,
                    MAX( --if 0 then no other subscriptions starting earlier, meaning joiner
                        CASE
                            WHEN s.CREATION_TIME BETWEEN dateToLong(TO_CHAR( TRUNC(SYSDATE,'MM'), 'YYYY-MM-dd HH24:MI')) AND dateToLong(TO_CHAR( TRUNC(SYSDATE), 'YYYY-MM-dd HH24:MI')) --started,
                                --  AND s2.STATE = 1
                                AND s2.END_DATE BETWEEN TRUNC(SYSDATE,'MM') AND TRUNC(SYSDATE)
                                AND s2.OWNER_CENTER !=s.OWNER_CENTER --had a subscription on another member ending this month.
                                --not first subscription,
                            THEN 1
                            ELSE 0
                        END) AS trans_to,
                    SUM( --if 0 then no other subscriptions starting earlier, meaning joiner
                        CASE
                            WHEN s.CREATION_TIME BETWEEN dateToLong(TO_CHAR( TRUNC(SYSDATE,'MM'), 'YYYY-MM-dd HH24:MI')) AND dateToLong(TO_CHAR( TRUNC(SYSDATE), 'YYYY-MM-dd HH24:MI')) --started,
                                AND s2.END_DATE < s.START_DATE-30
                                --had a subscription on another member ending this month.
                                --not first subscription,
                            THEN 1
                            ELSE 0
                        END) AS is_rejoin
                FROM
                    PUREGYM.PERSONS p
                JOIN
                    PUREGYM.SUBSCRIPTIONS s
                ON
                    s.OWNER_CENTER = p.center
                    AND s.OWNER_ID = p.id
                    AND (
                        s.END_DATE BETWEEN TRUNC(SYSDATE,'MM') AND TRUNC(SYSDATE)
                        OR s.CREATION_TIME BETWEEN dateToLong(TO_CHAR( TRUNC(SYSDATE,'MM'), 'YYYY-MM-dd HH24:MI')) AND dateToLong(TO_CHAR( TRUNC(SYSDATE), 'YYYY-MM-dd HH24:MI')) )
                    AND (
                        s.END_DATE >= s.START_DATE
                        OR s.END_DATE IS NULL )
                JOIN
                    PUREGYM.SUBSCRIPTIONTYPES st
                ON
                    st.CENTER = s.SUBSCRIPTIONTYPE_CENTER
                    AND st.id = s.SUBSCRIPTIONTYPE_ID
                    AND (ST.CENTER, ST.ID) not in (select center, id from V_EXCLUDED_SUBSCRIPTIONS) 
                LEFT JOIN
                    PUREGYM.PERSONS p2
                ON
                    p.CURRENT_PERSON_CENTER = p2.CURRENT_PERSON_CENTER
                    AND p.CURRENT_PERSON_ID = p2.CURRENT_PERSON_ID
                LEFT JOIN
                    PUREGYM.SUBSCRIPTIONS s2
                ON
                    s2.OWNER_CENTER = p2.CENTER
                    AND s2.OWNER_ID = p2.ID
                    AND (
                        s2.END_DATE >= s2.START_DATE
                        OR s2.END_DATE IS NULL )
                    AND (
                        s2.center != s.center
                        OR s2.id != s.id)
                LEFT JOIN
                    PUREGYM.SUBSCRIPTIONTYPES st2
                ON
                    st2.CENTER = s2.SUBSCRIPTIONTYPE_CENTER
                    AND st2.id = s2.SUBSCRIPTIONTYPE_ID
                    AND (ST2.CENTER, ST2.ID) not in (select center, id from V_EXCLUDED_SUBSCRIPTIONS) 
                WHERE
                    p.center IN($$scope$$)
                    --   AND p.id = 30847
                    AND (
                        s2.center IS NULL
                        OR st2.center IS NOT NULL)
                GROUP BY
                    p.CENTER,
                    p.ID,
                    p.ZIPCODE)
        GROUP BY
            center,
            zipcode) a
JOIN
    PUREGYM.CENTERS c
ON
    c.id = a.center