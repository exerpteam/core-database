-- The extract is extracted from Exerp on 2026-02-08
-- https://clublead.atlassian.net/browse/ES-17413
 WITH
     PARAMS AS MATERIALIZED
     (
         SELECT 
             ID ,
             datetolongTZ(TO_CHAR(TRUNC(current_timestamp-1 , 'DDD'), 'YYYY-MM-DD HH24:MI'),  'Europe/London') AS STARTTIME ,
             datetolongTZ(TO_CHAR(TRUNC(current_timestamp , 'DDD'), 'YYYY-MM-DD HH24:MI'),    'Europe/London') AS ENDTIME,
             datetolongTZ(TO_CHAR(TRUNC(current_timestamp+1, 'DDD'), 'YYYY-MM-DD HH24:MI'),'Europe/London') AS HARDCLOSETIME
         FROM
                  centers
             WHERE ID in (:scope)
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
    ),
     INCLUDED_ST as (
         select distinct st1.center, st1.id from
         SUBSCRIPTIONTYPES st1
         cross join params
         where
                  st1.center = params.ID
                 and (st1.center, st1.id) not in (select center,id from V_EXCLUDED_SUBSCRIPTIONS where center = params.ID)
     )
 SELECT
     OWNER_CENTER AS Center, COUNT(*) AS "Joiner Count"
 FROM
     (
         -- Outoing balance members
         SELECT DISTINCT
             SU.OWNER_CENTER,
             SU.OWNER_ID
         FROM
             PARAMS,
             INCLUDED_ST ST
         JOIN
             SUBSCRIPTIONS SU
         ON
             SU.SUBSCRIPTIONTYPE_CENTER = ST.CENTER
         AND SU.SUBSCRIPTIONTYPE_ID = ST.ID
         WHERE
 --      ST.ST_TYPE = 1
 --(ST.CENTER, ST.ID) not in (select /*+ materialize */ center, id from V_EXCLUDED_SUBSCRIPTIONS) -- 17/09/2015 ST-421 Changed from st type = 1
 --        AND
 SU.CENTER = PARAMS.ID
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
         EXCEPT
         -- That are not in incoming balance
         SELECT DISTINCT
             SU.OWNER_CENTER,
             SU.OWNER_ID
         FROM
             PARAMS,
             INCLUDED_ST ST
         JOIN
             SUBSCRIPTIONS SU
         ON
             SU.SUBSCRIPTIONTYPE_CENTER = ST.CENTER
         AND SU.SUBSCRIPTIONTYPE_ID = ST.ID
         WHERE
 --      ST.ST_TYPE = 1
 --         (ST.CENTER, ST.ID) not in (select /*+ materialize */ center, id from V_EXCLUDED_SUBSCRIPTIONS) -- 17/09/2015 ST-421 Changed from st type = 1
 --        AND
 SU.CENTER = PARAMS.ID
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
                 AND SCL.STATEID IN ( 2,
                                     4,8)
                     -- Time safety. We need to exclude subscriptions started in the past so they do
                     -- not
                     -- get
                     -- into the incoming balance because they will not be in the outgoing balance
                     -- of
                     -- the
                     -- previous day
                 AND SCL.ENTRY_START_TIME < PARAMS.STARTTIME ) ) t1
                  group by owner_center
