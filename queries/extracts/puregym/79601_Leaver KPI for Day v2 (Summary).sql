-- The extract is extracted from Exerp on 2026-02-08
-- Output gives Leavers KPI as a count per club.
WITH PARAMS as materialized
 (
         SELECT 
             datetolongTZ(TO_CHAR(CAST(:For_Date AS DATE), 'YYYY-MM-DD HH24:MI'), 'Europe/London') AS STARTTIME,
             datetolongTZ(TO_CHAR(CAST(:For_Date AS DATE)+1, 'YYYY-MM-DD HH24:MI'), 'Europe/London') AS ENDTIME
     ),
     V_EXCLUDED_SUBSCRIPTIONS AS materialized
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
     INCLUDED_ST as 
     (
         select distinct st1.center, st1.id from
            SUBSCRIPTIONTYPES st1
         cross join 
            params 
         where
			st1.center in (:Scope)
            AND (st1.center, st1.id) not in (select center,id from V_EXCLUDED_SUBSCRIPTIONS where center in (:Scope))
 )
 SELECT OWNER_CENTER AS CENTER, count(*) AS Leavers_for_day
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
             (
             SCL.CENTER in (:Scope)
         -- Time safety. We need to exclude subscriptions started in the past so they do not get
         -- into the incoming balance because they will not be in the outgoing balance of the
         -- previous day
             AND SCL.ENTRY_START_TIME < PARAMS.STARTTIME
             AND SCL.BOOK_START_TIME < PARAMS.STARTTIME
             AND (
                     SCL.BOOK_END_TIME IS NULL
                 OR  SCL.BOOK_END_TIME >= PARAMS.STARTTIME )
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
             AND (ST.CENTER, ST.ID) not in (select center, id from V_EXCLUDED_SUBSCRIPTIONS where center in (:Scope))
      )
 EXCEPT
         SELECT DISTINCT
             SU.OWNER_CENTER,
             SU.OWNER_ID
         FROM
              PARAMS
         JOIN
             STATE_CHANGE_LOG SCL
         ON
             (
              SCL.CENTER in (:Scope)
         -- Time safety. We need to exclude subscriptions started in the past so they do not get
         -- into the incoming balance because they will not be in the outgoing balance of the
         -- previous day
             AND SCL.ENTRY_START_TIME < PARAMS.ENDTIME
             AND SCL.BOOK_START_TIME < PARAMS.ENDTIME
             AND (
                     SCL.BOOK_END_TIME IS NULL
                 OR  SCL.BOOK_END_TIME >= PARAMS.ENDTIME )
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
             AND (ST.CENTER, ST.ID) not in (select center, id from V_EXCLUDED_SUBSCRIPTIONS where center in (:Scope))
      )
 ) t1
        group by owner_center