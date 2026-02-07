WITH
    PARAMS AS
    (
        SELECT
            /*+ materialize */
            $$scope$$                                                                               AS CENTER ,
            datetolongTZ(TO_CHAR(TRUNC(start_date , 'DDD'), 'YYYY-MM-DD HH24:MI'), 'Europe/London' ) AS STARTTIME ,
            datetolongTZ(TO_CHAR(TRUNC(end_date, 'DDD'), 'YYYY-MM-DD HH24:MI'), 'Europe/London')     AS ENDTIME,
            datetolongTZ(TO_CHAR(TRUNC(end_date +1, 'DDD'), 'YYYY-MM-DD HH24:MI'), 'Europe/London')  AS HARDCLOSETIME,
            -- REJOINDURATION: in the last 365 days
            365*24*3600*1000 AS REJOINDURATION,
            -- REACTIVATEDURATION: in the last 31 days
            31*24*3600*1000 AS REINSTATEDURATION
        FROM
            (
                SELECT
                    $$start_date$$ AS start_date,
                    $$end_date$$ AS end_date
                FROM
                    DUAL )
    )
SELECT DISTINCT
    NVL(c.name,'_Total') AS Center,
    CASE
        WHEN c.STARTUPDATE>SYSDATE
        THEN 'Pre-Join'
        WHEN c.STARTUPDATE IS NULL
        THEN NULL
        ELSE 'Open'
    END    AS C_STATUS,
    A.NAME AS REGION,
    SUM(
        CASE
            WHEN pos.owner_center IS NULL
            THEN il.TOTAL_AMOUNT
            ELSE 0
        END) AS Existing_members,
    SUM(
        CASE
            WHEN joiners.owner_center IS NOT NULL
            THEN il.TOTAL_AMOUNT
            ELSE 0
        END) AS joiners,
    SUM(
        CASE
            WHEN joiners.owner_center IS NULL
                AND pos.owner_center IS NOT NULL
            THEN il.TOTAL_AMOUNT
            ELSE 0
        END) AS Rejoiners,
    sum(il.TOTAL_AMOUNT) AS total
FROM
    PARAMS,
    PUREGYM.subscriptions s
JOIN
    PUREGYM.INVOICELINES il
ON
    s.INVOICELINE_CENTER = il.CENTER
    AND s.INVOICELINE_ID = il.ID
    AND s.INVOICELINE_SUBID = il.SUBID
JOIN
    PUREGYM.INVOICES inv
ON
    inv.CENTER = il.CENTER
    AND inv.id = il.ID
JOIN
    PUREGYM.CENTERS c
ON
    inv.CENTER = c.ID
JOIN
    PUREGYM.AREA_CENTERS AC
ON
    c.ID = AC.CENTER
JOIN
    PUREGYM.AREAS A
ON
    A.ID = AC.AREA
    AND A.PARENT = 61
LEFT JOIN
    (
        -- Outoing balance members
        SELECT DISTINCT
            SU.OWNER_CENTER,
            SU.OWNER_ID
        FROM
            PARAMS,
            SUBSCRIPTIONTYPES ST
        JOIN
            SUBSCRIPTIONS SU
        ON
            SU.SUBSCRIPTIONTYPE_CENTER = ST.CENTER
            AND SU.SUBSCRIPTIONTYPE_ID = ST.ID
        WHERE
            ST.ST_TYPE IN (1)
            AND SU.CENTER IN ($$scope$$)
            AND EXISTS
            (
                -- In outgoing balance
                SELECT
                    1
                FROM
                    STATE_CHANGE_LOG SCL
                WHERE
                    SCL.CENTER = SU.CENTER
                    AND SCL.ID = SU.ID
                    AND SCL.ENTRY_TYPE = 2
                    AND SCL.BOOK_START_TIME < PARAMS.ENDTIME
                    AND (
                        SCL.BOOK_END_TIME IS NULL
                        OR SCL.ENTRY_END_TIME >= PARAMS.HARDCLOSETIME
                        OR SCL.BOOK_END_TIME >= PARAMS.ENDTIME )
                    AND SCL.ENTRY_TYPE = 2
                    AND SCL.STATEID IN ( 2,
                                        4,8)
                    -- Time safety. We need to exclude subscriptions started in the past so they do
                    -- not
                    -- get
                    -- into the incoming balance because they will not be in the outgoing balance
                    -- of
                    -- the
                    -- previous day
                    AND SCL.ENTRY_START_TIME < PARAMS.ENDTIME )
        MINUS
        -- That are not in incoming balance
        SELECT DISTINCT
            SU.OWNER_CENTER,
            SU.OWNER_ID
        FROM
            PARAMS,
            SUBSCRIPTIONTYPES ST
        JOIN
            SUBSCRIPTIONS SU
        ON
            SU.SUBSCRIPTIONTYPE_CENTER = ST.CENTER
            AND SU.SUBSCRIPTIONTYPE_ID = ST.ID
        WHERE
            ST.ST_TYPE IN (1)
            AND SU.CENTER IN ($$scope$$)
            AND EXISTS
            (
                -- In outgoing balance
                SELECT
                    1
                FROM
                    STATE_CHANGE_LOG SCL
                WHERE
                    SCL.CENTER = SU.CENTER
                    AND SCL.ID = SU.ID
                    AND SCL.ENTRY_TYPE = 2
                    AND SCL.BOOK_START_TIME < PARAMS.STARTTIME
                    AND (
                        SCL.BOOK_END_TIME IS NULL
                        OR SCL.ENTRY_END_TIME >= PARAMS.HARDCLOSETIME
                        OR SCL.BOOK_END_TIME >= PARAMS.STARTTIME )
                    AND SCL.ENTRY_TYPE = 2
                    AND SCL.STATEID IN ( 2,
                                        4,8)
                    -- Time safety. We need to exclude subscriptions started in the past so they do
                    -- not
                    -- get
                    -- into the incoming balance because they will not be in the outgoing balance
                    -- of
                    -- the
                    -- previous day
                    AND SCL.ENTRY_START_TIME < PARAMS.STARTTIME )) pos
ON
    pos.owner_center = s.OWNER_CENTER
    AND pos.owner_id = s.OWNER_ID
LEFT JOIN
    (
        SELECT
            SU.OWNER_CENTER,
            SU.OWNER_ID
        FROM
            PARAMS,
            STATE_CHANGE_LOG SCL
        JOIN
            SUBSCRIPTIONS SU
        ON
            SCL.CENTER = SU.CENTER
            AND SCL.ID = SU.ID
            AND SCL.ENTRY_TYPE = 2
        JOIN
            SUBSCRIPTIONTYPES ST
        ON
            SU.SUBSCRIPTIONTYPE_CENTER = ST.CENTER
            AND SU.SUBSCRIPTIONTYPE_ID = ST.ID
        WHERE
            SCL.CENTER IN ($$scope$$)
            -- we need to use entry time for time safety (retrospective sales)
            AND SCL.ENTRY_START_TIME < PARAMS.ENDTIME
            AND SCL.ENTRY_START_TIME >= PARAMS.STARTTIME
            AND SCL.ENTRY_TYPE = 2
            -- STARTTIME <= Creatd < ENDTIME
            AND SCL.STATEID = 8
            AND ST.ST_TYPE =1
            -- Not transferred (they are not joiners)
            AND SCL.SUB_STATE != 6
            AND NOT EXISTS
            (
                -- The subscription should not be ended/window the same day (cancellation)
                SELECT
                    1
                FROM
                    STATE_CHANGE_LOG SCL2
                WHERE
                    SCL2.ENTRY_TYPE = 2
                    AND SCL2.STATEID IN (3,7)
                    AND SCL2.CENTER = SU.CENTER
                    AND SCL2.ID = SU.ID
                    AND SCL2.ENTRY_START_TIME < PARAMS.ENDTIME
                    AND SCL2.ENTRY_START_TIME >= PARAMS.STARTTIME )
            AND NOT EXISTS
            (
                -- the member should not be in the incoming balance (otherwise not a joiner)
                --- !!! must be same SQL as incoming balance !!!
                SELECT
                    1
                FROM
                    SUBSCRIPTIONS SU2
                JOIN
                    SUBSCRIPTIONTYPES ST2
                ON
                    SU2.SUBSCRIPTIONTYPE_CENTER = ST2.CENTER
                    AND SU2.SUBSCRIPTIONTYPE_ID = ST2.ID
                JOIN
                    STATE_CHANGE_LOG SCL2
                ON
                    SCL2.CENTER = SU2.CENTER
                    AND SCL2.ID = SU2.ID
                    AND SCL2.ENTRY_TYPE = 2
                WHERE
                    SU2.OWNER_CENTER = SU.OWNER_CENTER
                    AND SU2.OWNER_ID = SU.OWNER_ID
                    AND ST2.ST_TYPE =1
                    AND SCL2.STATEID IN ( 2,
                                         4,8)
                    AND SCL2.BOOK_START_TIME < PARAMS.STARTTIME
                    AND (
                        SCL2.BOOK_END_TIME IS NULL
                        OR SCL2.BOOK_END_TIME >= PARAMS.STARTTIME )
                    -- Time safety. We need to exclude subscriptions started in the past so they do
                    -- not get
                    -- into the incoming balance because they will not be in the outgoing balance
                    -- of the
                    -- previous day
                    AND SCL2.ENTRY_START_TIME < PARAMS.STARTTIME)
            AND NOT EXISTS
            (
                -- has a membership of the same type that ended in the inactivty period ?
                SELECT
                    1
                FROM
                    SUBSCRIPTIONS SU2
                JOIN
                    SUBSCRIPTIONTYPES ST2
                ON
                    SU2.SUBSCRIPTIONTYPE_CENTER = ST2.CENTER
                    AND SU2.SUBSCRIPTIONTYPE_ID = ST2.ID
                JOIN
                    STATE_CHANGE_LOG SCL2
                ON
                    SCL2.CENTER = SU2.CENTER
                    AND SCL2.ID = SU2.ID
                    AND SCL2.ENTRY_TYPE = 2
                WHERE
                    SU2.OWNER_CENTER = SU.OWNER_CENTER
                    AND SU2.OWNER_ID = SU.OWNER_ID
                    AND ST2.ST_TYPE =1
                    AND SCL2.STATEID IN (3,7)
                    AND SCL2.BOOK_START_TIME < PARAMS.ENDTIME
                    AND SCL2.BOOK_START_TIME >= (SCL.BOOK_START_TIME-REJOINDURATION)) ) joiners
ON
    joiners.owner_center = s.OWNER_CENTER
    AND joiners.owner_id = s.OWNER_ID
LEFT JOIN
    (
        SELECT DISTINCT
            OWNER_CENTER,
            OWNER_ID
        FROM
            (
                SELECT
                    SU.OWNER_CENTER,
                    SU.OWNER_ID
                FROM
                    PARAMS,
                    STATE_CHANGE_LOG SCL
                JOIN
                    SUBSCRIPTIONS SU
                ON
                    SCL.CENTER = SU.CENTER
                    AND SCL.ID = SU.ID
                    AND SCL.ENTRY_TYPE = 2
                JOIN
                    SUBSCRIPTIONTYPES ST
                ON
                    SU.SUBSCRIPTIONTYPE_CENTER = ST.CENTER
                    AND SU.SUBSCRIPTIONTYPE_ID = ST.ID
                WHERE
                    SU.CENTER IN ($$scope$$)
                    -- we need to use entry time for time safety (retrospective sales)
                    AND SCL.ENTRY_START_TIME < PARAMS.ENDTIME
                    AND SCL.ENTRY_START_TIME >= PARAMS.STARTTIME
                    AND SCL.ENTRY_TYPE = 2
                    -- STARTTIME <= Creatd < ENDTIME
                    AND SCL.STATEID = 8
                    AND ST.ST_TYPE =1
                    -- Not transferred (they are not joiners)
                    AND SCL.SUB_STATE != 6
                    AND NOT EXISTS
                    (
                        -- The subscription should not be ended/window the same day (cancellation)
                        SELECT
                            1
                        FROM
                            STATE_CHANGE_LOG SCL2
                        WHERE
                            SCL2.ENTRY_TYPE = 2
                            AND SCL2.STATEID IN (3,7)
                            AND SCL2.CENTER = SU.CENTER
                            AND SCL2.ID = SU.ID
                            AND SCL2.ENTRY_START_TIME < PARAMS.ENDTIME
                            AND SCL2.ENTRY_START_TIME >= PARAMS.STARTTIME )
                    AND NOT EXISTS
                    (
                        -- the member should not be in the incoming balance (otherwise not a joiner)
                        --- !!! must be same SQL as incoming balance !!!
                        SELECT
                            1
                        FROM
                            SUBSCRIPTIONS SU2
                        JOIN
                            SUBSCRIPTIONTYPES ST2
                        ON
                            SU2.SUBSCRIPTIONTYPE_CENTER = ST2.CENTER
                            AND SU2.SUBSCRIPTIONTYPE_ID = ST2.ID
                        JOIN
                            STATE_CHANGE_LOG SCL2
                        ON
                            SCL2.CENTER = SU2.CENTER
                            AND SCL2.ID = SU2.ID
                            AND SCL2.ENTRY_TYPE = 2
                        WHERE
                            SU2.OWNER_CENTER = SU.OWNER_CENTER
                            AND SU2.OWNER_ID = SU.OWNER_ID
                            AND ST2.ST_TYPE =1
                            AND SCL2.STATEID IN ( 2,
                                                 4,8)
                            AND SCL2.BOOK_START_TIME < PARAMS.STARTTIME
                            AND (
                                SCL2.BOOK_END_TIME IS NULL
                                OR SCL2.BOOK_END_TIME >= PARAMS.STARTTIME )
                            -- Time safety. We need to exclude subscriptions started in the past so they do
                            -- not get
                            -- into the incoming balance because they will not be in the outgoing balance
                            -- of the
                            -- previous day
                            AND SCL2.ENTRY_START_TIME < PARAMS.STARTTIME)
                    AND EXISTS
                    (
                        -- has a membership of the same type that ended in the inactivty period ?
                        SELECT
                            1
                        FROM
                            SUBSCRIPTIONS SU2
                        JOIN
                            SUBSCRIPTIONTYPES ST2
                        ON
                            SU2.SUBSCRIPTIONTYPE_CENTER = ST2.CENTER
                            AND SU2.SUBSCRIPTIONTYPE_ID = ST2.ID
                        JOIN
                            STATE_CHANGE_LOG SCL2
                        ON
                            SCL2.CENTER = SU2.CENTER
                            AND SCL2.ID = SU2.ID
                            AND SCL2.ENTRY_TYPE = 2
                        WHERE
                            SU2.OWNER_CENTER = SU.OWNER_CENTER
                            AND SU2.OWNER_ID = SU.OWNER_ID
                            AND ST2.ST_TYPE =1
                            AND SCL2.STATEID IN (3,7)
                            AND SCL2.BOOK_START_TIME < PARAMS.ENDTIME
                            AND SCL2.BOOK_START_TIME >= (SCL.BOOK_START_TIME - REINSTATEDURATION)) )) reins
ON
    reins.owner_center= s.OWNER_CENTER
    AND reins.owner_id = s.OWNER_ID
WHERE
    s.CREATION_TIME BETWEEN PARAMS.STARTTIME AND PARAMS.ENDTIME
    AND s.STATE != 5
    AND c.id IN ($$scope$$)
    AND il.TOTAL_AMOUNT !=0
    AND reins.owner_center IS NULL
GROUP BY
    grouping sets ( (C.name,c.STARTUPDATE, A.NAME), () )
ORDER BY
    1