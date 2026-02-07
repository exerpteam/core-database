WITH
    PARAMS AS MATERIALIZED
    (   SELECT
            CAST(datetolongTZ(TO_CHAR(TRUNC(CAST($$For_Date$$ AS DATE), 'DDD'),
            'YYYY-MM-DD HH24:MI'), 'Europe/London') AS BIGINT) AS STARTTIME,
            CAST(datetolongTZ(TO_CHAR(TRUNC(CAST($$For_Date$$ AS DATE) +1, 'DDD'),
            'YYYY-MM-DD HH24:MI'), 'Europe/London') AS BIGINT) AS ENDTIME,
            CAST(datetolongTZ(TO_CHAR(TRUNC(CAST($$For_Date$$ AS DATE) +2, 'DDD'),
            'YYYY-MM-DD HH24:MI'), 'Europe/London') AS BIGINT) AS HARDCLOSETIME
    )
    ,
    V_EXCLUDED_SUBSCRIPTIONS AS MATERIALIZED
    (   SELECT
            ppgl.PRODUCT_CENTER AS center,
            ppgl.PRODUCT_ID     AS id
        FROM
            PRODUCT_AND_PRODUCT_GROUP_LINK ppgl
        JOIN
            PRODUCT_GROUP pg
            ON  pg.ID = ppgl.PRODUCT_GROUP_ID
        WHERE
            pg.EXCLUDE_FROM_MEMBER_COUNT = True
    )
SELECT
    cp.EXTERNAL_ID
FROM
    (   SELECT
            SU.OWNER_CENTER,
            SU.OWNER_ID
        FROM
            PARAMS
        JOIN
            STATE_CHANGE_LOG SCL
            ON (
                    SCL.CENTER IN ($$Scope$$)
                    -- Time safety. We need to exclude subscriptions started in the past so they
                    -- do not get
                    -- into the incoming balance because they will not be in the outgoing balance
                    -- of the
                    -- previous day
                    AND SCL.ENTRY_START_TIME < PARAMS.STARTTIME
                    AND SCL.BOOK_START_TIME < PARAMS.STARTTIME
                    AND
                    (
                        SCL.BOOK_END_TIME IS NULL
                        OR SCL.BOOK_END_TIME >= PARAMS.STARTTIME)
                    AND SCL.ENTRY_TYPE = 2
                    AND SCL.STATEID IN(2,
                                       4,
                                       8))
        INNER JOIN
            SUBSCRIPTIONS SU
            ON (
                    SCL.CENTER = SU.CENTER
                    AND SCL.ID = SU.ID
                    AND SCL.ENTRY_TYPE = 2)
        JOIN
            SUBSCRIPTIONTYPES ST
            ON (
                    SU.SUBSCRIPTIONTYPE_CENTER = ST.CENTER
                    AND SU.SUBSCRIPTIONTYPE_ID = ST.ID)
        LEFT JOIN
            V_EXCLUDED_SUBSCRIPTIONS ES
            ON  ES.CENTER = ST.CENTER
                AND ES.ID = ST.ID
        WHERE
            ES.id IS NULL
        
        EXCEPT
        
        SELECT
            SU.OWNER_CENTER,
            SU.OWNER_ID
        FROM
            PARAMS
        JOIN
            STATE_CHANGE_LOG SCL
            ON (
                    SCL.CENTER IN ($$Scope$$)
                    -- Time safety. We need to exclude subscriptions started in the past so they
                    -- do not get
                    -- into the incoming balance because they will not be in the outgoing balance
                    -- of the
                    -- previous day
                    AND SCL.ENTRY_START_TIME < PARAMS.ENDTIME
                    AND SCL.BOOK_START_TIME < PARAMS.ENDTIME
                    AND
                    (
                        SCL.BOOK_END_TIME IS NULL
                        OR SCL.BOOK_END_TIME >= PARAMS.ENDTIME)
                    AND SCL.ENTRY_TYPE = 2
                    AND SCL.STATEID IN(2,
                                       4,
                                       8))
        INNER JOIN
            SUBSCRIPTIONS SU
            ON (
                    SCL.CENTER = SU.CENTER
                    AND SCL.ID = SU.ID
                    AND SCL.ENTRY_TYPE = 2)
        JOIN
            SUBSCRIPTIONTYPES ST
            ON (
                    SU.SUBSCRIPTIONTYPE_CENTER = ST.CENTER
                    AND SU.SUBSCRIPTIONTYPE_ID = ST.ID)
        LEFT JOIN
            V_EXCLUDED_SUBSCRIPTIONS ES
            ON  ES.CENTER = ST.CENTER
                AND ES.ID = ST.ID
        WHERE
            ES.id IS NULL) t
JOIN
    PERSONS p
    ON  p.CENTER = OWNER_CENTER
        AND p.ID = OWNER_ID
JOIN
    PERSONS cp
    ON  cp.CENTER = p.CURRENT_PERSON_CENTER
        AND cp.ID = p.CURRENT_PERSON_ID