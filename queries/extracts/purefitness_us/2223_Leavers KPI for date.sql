-- The extract is extracted from Exerp on 2026-02-08
--  
WITH PARAMS as MATERIALIZED
(
	SELECT 
	    datetolongC(TO_CHAR(to_date(:From_Date,'yyyy-mm-dd'), 'YYYY-MM-DD HH24:MI'),c.id) AS DATETIME_before,
            datetolongC(TO_CHAR(to_date(:To_Date,'yyyy-mm-dd') + interval '1 days', 'YYYY-MM-DD HH24:MI'),c.id) AS DATETIME,
            id AS center_id
        FROM 
                    centers c
        WHERE
                c.id IN (:Scope)
                     
),
EXCLUDED_SUBSCRIPTIONS as 
(
       SELECT
                DISTINCT
                pr.center,
                pr.id
        FROM purefitnessus.products pr
        JOIN product_and_product_group_link ppgl ON pr.center = ppgl.product_center AND pr.id = ppgl.product_id
        JOIN purefitnessus.product_group pg ON pg.id = ppgl.product_group_id
        WHERE
                pg.exclude_from_member_count = true                
)
SELECT cp.EXTERNAL_ID
FROM
(
        SELECT 
            SU.OWNER_CENTER,
            SU.OWNER_ID
        FROM
             PARAMS
        JOIN
            STATE_CHANGE_LOG SCL
        ON
           scl.center = params.center_id
        -- Time safety. We need to exclude subscriptions started in the past so they do not get
        -- into the incoming balance because they will not be in the outgoing balance of the
        -- previous day
            AND SCL.ENTRY_START_TIME < PARAMS.DATETIME_before
            AND SCL.BOOK_START_TIME < PARAMS.DATETIME_before
            AND (
                    SCL.BOOK_END_TIME IS NULL
                OR  SCL.BOOK_END_TIME >= PARAMS.DATETIME_before )
            AND SCL.ENTRY_TYPE = 2
            AND SCL.STATEID IN ( 2,4,8)
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
            SU.SUBSCRIPTIONTYPE_CENTER = ST.CENTER
            AND SU.SUBSCRIPTIONTYPE_ID = ST.ID  
        WHERE
                (ST.CENTER, ST.ID) NOT IN (SELECT center,id FROM EXCLUDED_SUBSCRIPTIONS)
EXCEPT
        SELECT DISTINCT
            SU.OWNER_CENTER,
            SU.OWNER_ID
        FROM
             PARAMS
        JOIN
            STATE_CHANGE_LOG SCL
        ON
            scl.center = params.center_id
        -- Time safety. We need to exclude subscriptions started in the past so they do not get
        -- into the incoming balance because they will not be in the outgoing balance of the
        -- previous day
            AND SCL.ENTRY_START_TIME < PARAMS.DATETIME
            AND SCL.BOOK_START_TIME < PARAMS.DATETIME
            AND (
                    SCL.BOOK_END_TIME IS NULL
                OR  SCL.BOOK_END_TIME >= PARAMS.DATETIME )
            AND SCL.ENTRY_TYPE = 2
            AND SCL.STATEID IN ( 2,4,8)
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
            AND (ST.CENTER, ST.ID) not in (SELECT center,id FROM EXCLUDED_SUBSCRIPTIONS)
     ) 
) t1
JOIN
   PERSONS p
ON 
   p.CENTER = OWNER_CENTER
   AND p.ID = OWNER_ID
JOIN
   PERSONS cp
ON
   cp.CENTER = p.CURRENT_PERSON_CENTER
   AND cp.ID = p.CURRENT_PERSON_ID