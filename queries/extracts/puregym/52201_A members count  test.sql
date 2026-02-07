WITH PARAMS as 
(
                SELECT /*+ materialize */
                    ? AS CENTER ,
                    datetolongTZ(TO_CHAR(TRUNC(?+1 , 'DDD'), 'YYYY-MM-DD HH24:MI'),
                    'Europe/London') AS DATETIME
                FROM
                    DUAL )
SELECT /*+ NO_BIND_AWARE */
    COUNT(*)
FROM
    (
        SELECT DISTINCT
            SU.OWNER_CENTER,
            SU.OWNER_ID
        FROM
             PARAMS
        JOIN
            STATE_CHANGE_LOG SCL
        ON
            (
                SCL.CENTER = PARAMS.CENTER
        -- Time safety. We need to exclude subscriptions started in the past so they do not get
        -- into the incoming balance because they will not be in the outgoing balance of the
        -- previous day
            AND SCL.ENTRY_START_TIME < PARAMS.DATETIME
            AND SCL.BOOK_START_TIME < PARAMS.DATETIME
            AND (
                    SCL.BOOK_END_TIME IS NULL
                OR  SCL.BOOK_END_TIME >= PARAMS.DATETIME )
            AND SCL.ENTRY_TYPE = 2
            AND SCL.STATEID IN ( 2,
                                4,8))
        INNER JOIN
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
            AND (ST.CENTER, ST.ID) not in (select /*+ materialize */ center, id from V_EXCLUDED_SUBSCRIPTIONS where center = params.center) -- 17/09/2015 ST-421 Changed from st type = 1)
--	AND ST.ST_TYPE = 1            
     ) )