-- The extract is extracted from Exerp on 2026-02-08
--  
WITH
    PARAMS AS
    (
        SELECT /*+ materialize */
            :center_id AS CENTER,
            CAST (dateToLongTZ(TO_CHAR(d.currentdate, 'YYYY-MM-dd HH24:MI'), coalesce(ce.time_zone, co.defaulttimezone)) AS BIGINT)  AS STARTTIME,
            CAST (dateToLongTZ(TO_CHAR(d.currentdate+1, 'YYYY-MM-dd HH24:MI'), coalesce(ce.time_zone, co.defaulttimezone)) AS BIGINT)  AS ENDTIME,
            CAST (dateToLongTZ(TO_CHAR(d.currentdate+2, 'YYYY-MM-dd HH24:MI'), coalesce(ce.time_zone, co.defaulttimezone)) AS BIGINT)  AS HARDCLOSETIME
            
        FROM 
            centers ce
        LEFT JOIN
            countries co
        ON 
            ce.country = co.id
        CROSS JOIN
           (SELECT CAST(:currentdate AS DATE) AS currentdate) d
    )
    ,
    INCLUDED_ST as (
        select distinct st1.center, st1.id from 
        SUBSCRIPTIONTYPES st1
        cross join params
        where 
                 st1.center = params.center
				AND (st1.center, st1.id) NOT IN
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
                    pg.exclude_from_member_count = true
                AND ppgl.product_center = params.center)  
    )

SELECT  
 --COUNT(*)
p.external_id as person_id, x2.*, p.*
FROM
    (
        -- Outoing balance members
        SELECT DISTINCT
            SU.OWNER_CENTER,
            SU.OWNER_ID,
			SU.ID
        FROM
            PARAMS,
            INCLUDED_ST ST
        JOIN
            SUBSCRIPTIONS SU
        ON
            SU.SUBSCRIPTIONTYPE_CENTER = ST.CENTER
        AND SU.SUBSCRIPTIONTYPE_ID = ST.ID
        WHERE
            SU.CENTER = PARAMS.CENTER
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
                    OR  SCL.ENTRY_END_TIME >= PARAMS.HARDCLOSETIME
                    OR  SCL.BOOK_END_TIME >= PARAMS.ENDTIME )
                AND SCL.ENTRY_TYPE = 2
                AND SCL.STATEID IN ( 2, 4,8)
                    -- Time safety. We need to exclude subscriptions started in the past so they do
                    -- not
                    -- get
                    -- into the incoming balance because they will not be in the outgoing balance
                    -- of
                    -- the
                    -- previous day
                AND SCL.ENTRY_START_TIME < PARAMS.ENDTIME ) 
        EXCEPT
        -- That are not in incoming balance
        SELECT DISTINCT
            SU.OWNER_CENTER,
            SU.OWNER_ID,
			SU.ID
        FROM
            PARAMS,
            INCLUDED_ST ST
        JOIN
            SUBSCRIPTIONS SU
        ON
            SU.SUBSCRIPTIONTYPE_CENTER = ST.CENTER
        AND SU.SUBSCRIPTIONTYPE_ID = ST.ID
        WHERE
           SU.CENTER = PARAMS.CENTER
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
                    OR  SCL.ENTRY_END_TIME >= PARAMS.HARDCLOSETIME
                    OR  SCL.BOOK_END_TIME >= PARAMS.STARTTIME )
                AND SCL.ENTRY_TYPE = 2
                AND SCL.STATEID IN ( 2, 4,8)
                    -- Time safety. We need to exclude subscriptions started in the past so they do
                    -- not
                    -- get
                    -- into the incoming balance because they will not be in the outgoing balance
                    -- of
                    -- the
                    -- previous day
                AND SCL.ENTRY_START_TIME < PARAMS.STARTTIME ) ) x2

JOIN PERSONS p on p.id = x2.OWNER_ID and p.center = x2.OWNER_CENTER
--JOIN SUBSCRIPTIONS s on s.id = x2.id
