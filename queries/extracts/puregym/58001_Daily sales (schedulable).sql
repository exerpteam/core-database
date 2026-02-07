 WITH PARAMS AS MATERIALIZED
 (
         SELECT 
             ID,
             datetolongTZ(TO_CHAR(TRUNC(current_timestamp+1-:offset , 'DDD'), 'YYYY-MM-DD HH24:MI'),   'Europe/London') AS DATETIME,
             datetolongTZ(TO_CHAR(TRUNC(current_timestamp-:offset , 'DDD'), 'YYYY-MM-DD HH24:MI'), 'Europe/London') AS DATETIME_before,
         datetolongTZ(TO_CHAR(TRUNC(current_timestamp-:offset , 'DDD'), 'YYYY-MM-DD HH24:MI'), 'Europe/London') AS STARTTIME ,
         datetolongTZ(TO_CHAR(TRUNC(current_timestamp+1-:offset, 'DDD'), 'YYYY-MM-DD HH24:MI'),    'Europe/London') AS ENDTIME,
         datetolongTZ(TO_CHAR(TRUNC(current_timestamp +2-:offset, 'DDD'), 'YYYY-MM-DD HH24:MI'), 'Europe/London') AS HARDCLOSETIME,
                 TRUNC(current_timestamp-:offset) AS DATESTART
         FROM
              CENTERS
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
         CASE   WHEN c.SHORTNAME IS NULL  THEN '  Grand Total =' ELSE c.shortname END AS "Center Name",
         a.NAME AS "Region",
         CASE
                 WHEN c.STARTUPDATE>CURRENT_TIMESTAMP
                 THEN 'Pre-Join'
                 WHEN C.STARTUPDATE IS NULL
                 THEN NULL
                 ELSE 'Open'
         END                                           AS "Center Status",
         SUM(coalesce(totaljoiners.Joiner_Count,0)) "New",
         SUM(coalesce(leavers.Leavers_for_day,0)) "Cancel",
         SUM(coalesce(totaljoiners.Joiner_Count,0)-coalesce(leavers.Leavers_for_day,0)) "Net Gain",
         SUM(totalmembers.total_members) "Total Member"
 FROM
         CENTERS c
 JOIN
         AREA_CENTERS AC
 ON
        c.ID = AC.CENTER
 JOIN
        AREAS A
 ON
        A.ID = AC.AREA
        AND A.PARENT = 61
 JOIN
 (
 SELECT /*+ NO_BIND_AWARE */
      owner_center AS Center, count(*) AS total_members
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
             SUBSCRIPTIONTYPES ST
         ON
             (
                 SU.SUBSCRIPTIONTYPE_CENTER = ST.CENTER
             AND SU.SUBSCRIPTIONTYPE_ID = ST.ID
             AND (ST.CENTER, ST.ID) not in (select /*+ materialize */ center, id from V_EXCLUDED_SUBSCRIPTIONS where center = params.ID) -- 17/09/2015 ST-421 Changed from st type = 1)
 --      AND ST.ST_TYPE = 1
      )
      ) t1
        group by owner_center
 ) totalmembers
 ON totalmembers.center = c.id
 LEFT JOIN
 (
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
                 SCL.CENTER = params.ID
         -- Time safety. We need to exclude subscriptions started in the past so they do not get
         -- into the incoming balance because they will not be in the outgoing balance of the
         -- previous day
             AND SCL.ENTRY_START_TIME < PARAMS.DATETIME_before
             AND SCL.BOOK_START_TIME < PARAMS.DATETIME_before
             AND (
                     SCL.BOOK_END_TIME IS NULL
                 OR  SCL.BOOK_END_TIME >= PARAMS.DATETIME_before )
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
             AND (ST.CENTER, ST.ID) not in (select /*+ materialize */ center, id from V_EXCLUDED_SUBSCRIPTIONS where center = params.ID)
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
                 SCL.CENTER = params.ID
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
             SUBSCRIPTIONTYPES ST
         ON
             (
                 SU.SUBSCRIPTIONTYPE_CENTER = ST.CENTER
             AND SU.SUBSCRIPTIONTYPE_ID = ST.ID
             AND (ST.CENTER, ST.ID) not in (select /*+ materialize */ center, id from V_EXCLUDED_SUBSCRIPTIONS where center = params.ID)
      )
 ) t2
        group by owner_center
 ) leavers
 ON totalmembers.Center = leavers.center
 left join
 (
 SELECT
     OWNER_CENTER AS Center, COUNT(*) AS Joiner_Count
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
                 AND SCL.ENTRY_START_TIME < PARAMS.STARTTIME ) ) t3
                  group by owner_center
 ) totaljoiners
 ON totalmembers.center = totaljoiners.Center
 GROUP BY  GROUPING SETS ((C.SHORTNAME, A.NAME, C.STARTUPDATE), ())
 ORDER BY C.SHORTNAME
