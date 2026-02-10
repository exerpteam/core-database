-- The extract is extracted from Exerp on 2026-02-08
-- Fabric - Sub Test
WITH PARAMS as 
(
                SELECT /*+ materialize */
                    :CENTER AS CENTER,
                    CAST (dateToLongTZ(TO_CHAR(CAST(:DATE AS DATE)+1, 'YYYY-MM-dd HH24:MI'), coalesce(ce.time_zone, co.defaulttimezone)) AS BIGINT)  AS DATETIME
                 FROM 
                   centers ce
                 LEFT JOIN
                   countries co
                 ON 
                   ce.country = co.id
                 )
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
            AND SCL.STATEID IN ( 2, 4, 8))
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
            AND (
                    ST.CENTER, ST.ID) NOT IN
                (
                    SELECT
                        ppgl.product_center,
                        ppgl.product_id
                    FROM
                        product_and_product_group_link ppgl
                    JOIN
                        product_group pg
                    ON
                        pg.id = ppgl.product_group_id
                    WHERE
                        pg.exclude_from_member_count = true )
     )  ) x