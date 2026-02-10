-- The extract is extracted from Exerp on 2026-02-08
--  
WITH
    dates AS
    (
        SELECT
            /*+ materialize */
            datetolongTZ(TO_CHAR($$END_DATE$$ - ROWNUM+1,'YYYY-MM-DD') || ' 00:00', 'Europe/London') dt
        FROM
            DUAL CONNECT BY ROWNUM < $$END_DATE$$ - $$START_DATE$$+2
    )
SELECT
    ReportDate      AS "Date",
    ClubId          AS "ClubId",
    Club            AS "Club",
    PersonType      AS "Person Type",
    COUNT(PersonId) AS "Count"
FROM
    (
        SELECT DISTINCT
            TO_CHAR(longtodateC(dates.dt,c.ID),'yyyy-MM-dd')                                                                                                        AS ReportDate,
            su.center                                                                                                                                               AS ClubId,
            c.SHORTNAME                                                                                                                                             AS Club,
            DECODE (scl2.STATEID, 0,'Private', 1,'Student', 2,'Staff', 3,'Friend', 4,'Corporate', 5,'Onemancorporate', 6,'Family', 7,'Senior', 8,'Guest','Unknown') AS PersonType,
            su.OWNER_CENTER||'p'||su.OWNER_ID                                                                                                                       AS PersonId,
            rank() over (partition BY SCL2.center, SCL2.id ORDER BY SCL2.entry_start_time DESC)                                                                     AS rnk
        FROM
            dates
        JOIN
            STATE_CHANGE_LOG SCL
        ON
            (
                -- Time safety. We need to exclude subscriptions started in the past so they do not get
                -- into the incoming balance because they will not be in the outgoing balance of the
                -- previous day
                SCL.ENTRY_START_TIME < dates.dt+1000*60*60*24
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
            SUBSCRIPTIONTYPES ST
        ON
            (
                SU.SUBSCRIPTIONTYPE_CENTER = ST.CENTER
                AND SU.SUBSCRIPTIONTYPE_ID = ST.ID
                AND (
                    ST.CENTER, ST.ID) NOT IN
                (
                    SELECT
                        /*+ materialize */
                        center,
                        id
                    FROM
                        V_EXCLUDED_SUBSCRIPTIONS) )
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
                    OR SCL2.BOOK_END_TIME >= dates.dt)
                AND SCL2.ENTRY_TYPE = 3 )
        JOIN
            PUREGYM.CENTERS c
        ON
            c.id = su.center
        WHERE
            c.id IN ($$scope$$))
WHERE
    rnk = 1
GROUP BY
    ReportDate,
    ClubId,
    Club,
    PersonType