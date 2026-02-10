-- The extract is extracted from Exerp on 2026-02-08
--  
 WITH
     PARAMS AS
     (
         SELECT
             /*+ materialize */
             $$Center$$                                                                                AS CENTER,
             datetolongTZ(TO_CHAR(TRUNC(CAST($$For_Date$$ as date)+1 , 'DDD'), 'YYYY-MM-DD HH24:MI'), 'Europe/London') AS DATETIME
         
     )
     , V_EXCLUDED_SUBSCRIPTIONS AS
    (
        SELECT
            ppgl.PRODUCT_CENTER as center,
            ppgl.PRODUCT_ID as id
        FROM
            PRODUCT_AND_PRODUCT_GROUP_LINK ppgl
        JOIN
            PRODUCT_GROUP pg
        ON
            pg.ID = ppgl.PRODUCT_GROUP_ID
        WHERE
            pg.EXCLUDE_FROM_MEMBER_COUNT = True
    )
 SELECT
     t.PersonId,
     t.SUBSCRIPTIONID,
     t."Subscription State",
     t."Subscription Sub State",
     t.globalid AS "ProductGlobalId"
 FROM
     (
         SELECT DISTINCT
             SU.OWNER_CENTER || 'p' || SU.OWNER_ID                                                                                                                                                 AS PersonId,
             su.center || 'ss' || su.id                                                                                                                                                            AS SUBSCRIPTIONID,
             CASE  su.state  WHEN 2 THEN 'Active'  WHEN 3 THEN 'Ended'  WHEN 4 THEN 'Frozen'  WHEN 7 THEN 'Window'  WHEN 8 THEN 'Created' ELSE 'Unknown' END                                                                                               AS "Subscription State",
             CASE  su.SUB_STATE  WHEN 1 THEN 'NONE'  WHEN 2 THEN 'AWAITING_ACTIVATION'  WHEN 3 THEN 'UPGRADED'  WHEN 4 THEN 'DOWNGRADED'  WHEN 5 THEN 'EXTENDED'  WHEN 6 THEN  'TRANSFERRED' WHEN 7 THEN 'REGRETTED' WHEN 8 THEN 'CANCELLED' WHEN 9 THEN 'BLOCKED' WHEN 10 THEN 'CHANGED' ELSE 'UNKNOWN' END AS "Subscription Sub State",
             pr.globalid,
             rank() over (partition BY SU.OWNER_CENTER, SU.OWNER_ID ORDER BY su.state, su.creation_time) AS rnk
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
                     OR SCL.BOOK_END_TIME >= PARAMS.DATETIME )
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
                 AND (
                     ST.CENTER, ST.ID) NOT IN
                 (
                     SELECT
                         /*+ materialize */
                         center,
                         id
                     FROM
                         V_EXCLUDED_SUBSCRIPTIONS
                     WHERE
                         center = PARAMS.CENTER) -- 17/09/2015 ST-421 Changed from st type = 1)
                 -- AND ST.ST_TYPE = 1
             )
         JOIN
             PRODUCTS pr
         ON
             st.CENTER = pr.CENTER
             AND st.ID = pr.ID )t
 WHERE
     t.rnk = 1
