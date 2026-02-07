WITH
    dates AS
    (
        SELECT
            /*+ materialize */
            datetolongTZ(TO_CHAR($$END_DATE$$ - ROWNUM+1,'YYYY-MM-DD') || ' 00:00', 'Europe/London') dt
        FROM
            DUAL CONNECT BY ROWNUM < $$END_DATE$$ - $$START_DATE$$+2
    )
    ,
    INCLUDED_ST AS
    (
        SELECT DISTINCT
            st1.center,
            st1.id
        FROM
            SUBSCRIPTIONTYPES st1
        WHERE
            (
                st1.center, st1.id) NOT IN
            (
                SELECT
                    center,
                    id
                FROM
                    V_EXCLUDED_SUBSCRIPTIONS)
            AND EXISTS
            (
                SELECT
                    1
                FROM
                    subscriptions sub
                WHERE
                    sub.center IN($$scope$$)
                    AND sub.subscriptiontype_center = st1.center
                    AND sub.subscriptiontype_id = st1.id)
    )
SELECT
    TO_CHAR(longtodateC(dates.dt,c.ID),'yyyy-MM-dd')                                                                                                        AS "Date",
    su.center                                                                                                                                               AS "ClubId",
    c.SHORTNAME                                                                                                                                             AS "Club",
    DECODE (scl2.STATEID, 0,'Private', 1,'Student', 2,'Staff', 3,'Friend', 4,'Corporate', 5,'Onemancorporate', 6,'Family', 7,'Senior', 8,'Guest','Unknown') AS "Person Type",
    COUNT(DISTINCT su.OWNER_CENTER||'p'||su.OWNER_ID )                                                                                                      AS "Count"
FROM
    dates
JOIN
    STATE_CHANGE_LOG SCL
ON
    (
        SCL.CENTER IN($$scope$$)
        -- Time safety. We need to exclude subscriptions started in the past so they do not get
        -- into the incoming balance because they will not be in the outgoing balance of the
        -- previous day
        AND SCL.ENTRY_START_TIME < dates.dt+1000*60*60*24
        AND SCL.BOOK_START_TIME < dates.dt+1000*60*60*24
        AND (
            SCL.BOOK_END_TIME IS NULL
            OR SCL.BOOK_END_TIME >= dates.dt+1000*60*60*24 )
        AND SCL.ENTRY_TYPE IN (2)
        AND SCL.STATEID IN ( 2,
                            4,8) )
JOIN
    SUBSCRIPTIONS SU
ON
    (
        SCL.CENTER = SU.CENTER
        AND SCL.ID = SU.ID
        AND SCL.ENTRY_TYPE = 2 )
JOIN
    INCLUDED_ST
ON
    (
        SU.SUBSCRIPTIONTYPE_CENTER = INCLUDED_ST.CENTER
        AND SU.SUBSCRIPTIONTYPE_ID = INCLUDED_ST.ID )
JOIN
    STATE_CHANGE_LOG SCL2
ON
    (
        SCL2.CENTER = su.OWNER_CENTER
        AND scl2.id = su.OWNER_ID
        -- Time safety. We need to exclude subscriptions started in the past so they do not get
        -- into the incoming balance because they will not be in the outgoing balance of the
        -- previous day
        AND SCL2.ENTRY_START_TIME < dates.dt+1000*60*60*24
        AND SCL2.BOOK_START_TIME < dates.dt+1000*60*60*24
        AND (
            SCL2.BOOK_END_TIME IS NULL
            OR SCL2.BOOK_END_TIME >= dates.dt+1000*60*60*24 )
        AND SCL2.ENTRY_TYPE = 3 )
JOIN
    PUREGYM.CENTERS c
ON
    c.id = su.center
WHERE
    NOT EXISTS
    (
        -- In outgoing balance
        SELECT
            1
        FROM
            INCLUDED_ST ST2
        JOIN
            SUBSCRIPTIONS SU2
        ON
            SU2.SUBSCRIPTIONTYPE_CENTER = ST2.CENTER
            AND SU2.SUBSCRIPTIONTYPE_ID = ST2.ID
        JOIN
            STATE_CHANGE_LOG SCL3
        ON
            SCL3.CENTER = SU2.CENTER
            AND SCL3.ID = SU2.ID
            AND SCL3.ENTRY_TYPE = 2
            AND SCL3.STATEID IN ( 2,
                                 4,8)
        WHERE
            su2.OWNER_CENTER =su.OWNER_CENTER
            AND su2.OWNER_ID = su.OWNER_ID
            AND SCL3.BOOK_START_TIME < dates.dt
            AND (
                SCL3.BOOK_END_TIME IS NULL
                OR SCL3.BOOK_END_TIME >= dates.dt
                OR SCL3.ENTRY_END_TIME >= dates.dt+1000*60*60*24 )
            -- Time safety. We need to exclude subscriptions started in the past so they do
            -- not
            -- get
            -- into the incoming balance because they will not be in the outgoing balance
            -- of
            -- the
            -- previous day
            AND SCL3.ENTRY_START_TIME < dates.dt )
GROUP BY
    TO_CHAR(longtodateC(dates.dt,c.ID),'yyyy-MM-dd') ,
    su.center,
    c.SHORTNAME,
    scl2.STATEID