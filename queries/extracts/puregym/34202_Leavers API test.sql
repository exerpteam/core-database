WITH
    PARAMS AS
    (
        SELECT
            datetolongTZ(TO_CHAR(TRUNC(startdate , 'DDD'), 'YYYY-MM-DD HH24:MI'), 'Europe/London' )  AS STARTTIME ,
            datetolongTZ(TO_CHAR(TRUNC(endtdate, 'DDD'), 'YYYY-MM-DD HH24:MI'), 'Europe/London') AS ENDTIME,
            datetolongTZ(TO_CHAR(TRUNC(endtdate +1, 'DDD'), 'YYYY-MM-DD HH24:MI'), 'Europe/London') AS HARDCLOSETIME
        FROM
            (
                SELECT
                    $$from_date$$ AS startdate,
                    $$to_date$$ AS endtdate
                FROM
                    DUAL )
    )
SELECT
    Z as "Street Post Code",
    ST as "Levers SPC",
    CASE
        WHEN SUBSTR(RE,-1,1)=' '
        THEN SUBSTR(RE,0,LENGTH(RE)-1)
        ELSE RE
    END AS "Region Post Code",
    SUM(ST) over (partition BY
    CASE
        WHEN SUBSTR(RE,-1,1)=' '
        THEN SUBSTR(RE,0,LENGTH(RE)-1)
        ELSE RE
    END) as "Leavers RPC"
FROM
    (
        SELECT
            p.ZIPCODE                               Z,
            COUNT(DISTINCT p.center||'p'||p.id)     AS ST,
            SUBSTR(p.ZIPCODE,0,LENGTH(p.ZIPCODE)-3)    RE
        FROM
            (
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
                  
                    SU.CENTER in ($$scope$$)
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
                            -- Time safety. We need to exclude subscriptions
                            -- started in the past so they do
                            -- not
                            -- get
                            -- into the incoming balance because they will
                            -- not be in the outgoing balance
                            -- of
                            -- the
                            -- previous day
                            AND SCL.ENTRY_START_TIME < PARAMS.STARTTIME )
                MINUS
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
                      SU.CENTER in ($$scope$$)
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
                            -- Time safety. We need to exclude subscriptions      -- started in the past so they do
                            -- not
                            -- get
                            -- into the incoming balance because they will
                            -- not be in the outgoing balance
                            -- of
                            -- the
                            -- previous day
                            AND SCL.ENTRY_START_TIME < PARAMS.ENDTIME ) ) LEAVERS
        JOIN
            PERSONS p
        ON
            p.center = leavers.owner_center
            AND p.id = leavers.owner_id
        WHERE
            p.status IN (0,2,6,9)
        GROUP BY
            p.ZIPCODE)