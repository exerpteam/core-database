 WITH PARAMS as MATERIALIZED
 (
                 SELECT
                     ID,
                     CAST(datetolongTZ(TO_CHAR(cast(:for_date as date)+1, 'YYYY-MM-DD HH24:MI'),'Europe/London') AS BIGINT) AS DATETIME
                 FROM
                     centers
                WHERE ID in (56)
                 ),
    V_EXCLUDED_SUBSCRIPTIONS AS
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
         params.id,
         COUNT(DISTINCT (p.transfers_current_prs_center, p.transfers_current_prs_id)) AS distinct_count
         FROM
              PARAMS
         JOIN
             STATE_CHANGE_LOG SCL
         ON
             (
                 SCL.CENTER = PARAMS.ID
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
             PERSONS p
         ON
             SU.owner_center = p.center
             AND SU.owner_id = p.id         
         JOIN
             SUBSCRIPTIONTYPES ST
         ON
             (
                 SU.SUBSCRIPTIONTYPE_CENTER = ST.CENTER
             AND SU.SUBSCRIPTIONTYPE_ID = ST.ID
             AND (ST.CENTER, ST.ID) not in (select /*+ materialize */ center, id from V_EXCLUDED_SUBSCRIPTIONS where center = params.ID) -- 17/09/2015 ST-421 Changed from st type = 1)
 --      AND ST.ST_TYPE = 1
     )
      group by params.id
        