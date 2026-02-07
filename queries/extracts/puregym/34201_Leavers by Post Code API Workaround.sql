
SELECT
    Z  AS "Street Post Code",
    ST AS "Levers SPC",
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
    END) AS "Leavers RPC"
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
                    SUBSCRIPTIONTYPES ST
                JOIN
                    SUBSCRIPTIONS SU
                ON
                    SU.SUBSCRIPTIONTYPE_CENTER = ST.CENTER
                AND SU.SUBSCRIPTIONTYPE_ID = ST.ID
                WHERE
                    (
                        ST.CENTER, ST.ID) NOT IN
                    (
                        SELECT
                            center,
                            id
                        FROM
                            V_EXCLUDED_SUBSCRIPTIONS)
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
                        AND SCL.BOOK_START_TIME < :from_date
                        AND (
                                SCL.BOOK_END_TIME IS NULL
                            OR  SCL.ENTRY_END_TIME >= :to_date +(1000*3600*24)
                            OR  SCL.BOOK_END_TIME >= :from_date )
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
                        AND SCL.ENTRY_START_TIME < :from_date )
                MINUS
                -- Outoing balance members
                SELECT DISTINCT
                    SU.OWNER_CENTER,
                    SU.OWNER_ID
                FROM
                    SUBSCRIPTIONTYPES ST
                JOIN
                    SUBSCRIPTIONS SU
                ON
                    SU.SUBSCRIPTIONTYPE_CENTER = ST.CENTER
                AND SU.SUBSCRIPTIONTYPE_ID = ST.ID
                WHERE
                    (
                        ST.CENTER, ST.ID) NOT IN
                    (
                        SELECT
                            center,
                            id
                        FROM
                            V_EXCLUDED_SUBSCRIPTIONS)
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
                        AND SCL.BOOK_START_TIME < :to_date
                        AND (
                                SCL.BOOK_END_TIME IS NULL
                            OR  SCL.ENTRY_END_TIME >= :to_date +(1000*3600*24)
                            OR  SCL.BOOK_END_TIME >= :to_date )
                        AND SCL.ENTRY_TYPE = 2
                        AND SCL.STATEID IN ( 2,
                                            4,8)
                            -- Time safety. We need to exclude subscriptions      -- started in the
                            -- past so they do
                            -- not
                            -- get
                            -- into the incoming balance because they will
                            -- not be in the outgoing balance
                            -- of
                            -- the
                            -- previous day
                        AND SCL.ENTRY_START_TIME < :to_date ) ) LEAVERS
        JOIN
            PERSONS p
        ON
            p.center = leavers.owner_center
        AND p.id = leavers.owner_id
        WHERE
            p.status IN (0,2,6,9)
        GROUP BY
            p.ZIPCODE)