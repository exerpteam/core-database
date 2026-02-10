-- The extract is extracted from Exerp on 2026-02-08
-- https://clublead.atlassian.net/browse/ES-17413
 WITH PARAMS as
 (
         SELECT /*+ materialize */
             ID,
             datetolongTZ(TO_CHAR(TRUNC(current_timestamp+1, 'DDD'), 'YYYY-MM-DD HH24:MI'),   'Europe/London') AS DATETIME,
             datetolongTZ(TO_CHAR(TRUNC(current_timestamp , 'DDD'), 'YYYY-MM-DD HH24:MI'), 'Europe/London') AS DATETIME_before,
         datetolongTZ(TO_CHAR(TRUNC(current_timestamp , 'DDD'), 'YYYY-MM-DD HH24:MI'), 'Europe/London') AS STARTTIME ,
         datetolongTZ(TO_CHAR(TRUNC(current_timestamp+1, 'DDD'), 'YYYY-MM-DD HH24:MI'),    'Europe/London') AS ENDTIME,
         datetolongTZ(TO_CHAR(TRUNC(current_timestamp +2, 'DDD'), 'YYYY-MM-DD HH24:MI'), 'Europe/London') AS HARDCLOSETIME,
                 TRUNC(current_timestamp) AS DATESTART
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
    )
    ,
     
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
      ) t
        group by owner_center
 ) totalmembers
 ON totalmembers.center = c.id
 LEFT JOIN
 (
 SELECT
     p.center,
     COUNT(DISTINCT p.CENTER || 'p' || p.ID) AS Leavers_for_day
 FROM
     SUBSCRIPTIONS sub
 CROSS JOIN
  params
 JOIN
     STATE_CHANGE_LOG SCL1
 ON
     (
         SCL1.CENTER = SUB.CENTER
         AND SCL1.ID = SUB.ID
         AND SCL1.ENTRY_TYPE = 2 )
 INNER JOIN
     SUBSCRIPTIONTYPES ST
 ON
     (
         SUB.SUBSCRIPTIONTYPE_CENTER = ST.CENTER
         AND SUB.SUBSCRIPTIONTYPE_ID = ST.ID)
 JOIN
     PERSONS p
 ON
     p.center = sub.OWNER_CENTER
     AND p.id = sub.owner_id
 JOIN
     SUBSCRIPTION_CHANGE sc
 ON
     sc.OLD_SUBSCRIPTION_CENTER = sub.center
     AND sc.OLD_SUBSCRIPTION_ID = sub.id
     AND sc.TYPE = 'END_DATE'
     AND sc.CANCEL_TIME is null
     --AND sc.CHANGE_TIME <= params.DATETIME
 LEFT JOIN
     SUBSCRIPTION_CHANGE sc2
 ON
     sc2.OLD_SUBSCRIPTION_CENTER = sub.center
     AND sc2.OLD_SUBSCRIPTION_ID = sub.id
     AND sc2.TYPE = 'END_DATE'
     AND sc2.CANCEL_TIME is not null
     AND sc2.id > sc.id
 WHERE
     sc.EFFECT_DATE >= params.DATESTART
     AND sc.EFFECT_DATE < params.DATESTART + 1
     AND SCL1.STATEID IN (2,4,8)
     AND SCL1.BOOK_START_TIME < params.DATETIME_before
     AND (
         SCL1.BOOK_END_TIME IS NULL
         OR SCL1.BOOK_END_TIME >= params.DATETIME_before)
     AND SCL1.ENTRY_START_TIME < params.DATETIME_before
 -- AND ST.ST_TYPE = 1
     AND SUB.CENTER = PARAMS.ID AND (ST.CENTER, ST.ID) not in (select center, id from V_EXCLUDED_SUBSCRIPTIONS)
     AND sc2.id IS NULL
     AND sub.center = params.ID
     AND (
         sc.CANCEL_TIME IS NULL
         )
     -- exclude if the member has another DD subscription with an end date that is later or null,
     -- taking into account transfers
     AND NOT EXISTS
     (
         SELECT
             1
         FROM
             SUBSCRIPTIONS SU2
         JOIN
             persons p2
         ON
             p2.center = su2.OWNER_CENTER
             AND p2.id = su2.OWNER_ID
         JOIN
             STATE_CHANGE_LOG SCL2
         ON
             (
                 SCL2.CENTER = SU2.CENTER
                 AND SCL2.ID = SU2.ID
                 AND SCL2.ENTRY_TYPE = 2 )
         INNER JOIN
             SUBSCRIPTIONTYPES ST2
         ON
             (
                 SU2.SUBSCRIPTIONTYPE_CENTER = ST2.CENTER
                 AND SU2.SUBSCRIPTIONTYPE_ID = ST2.ID)
         WHERE
             SCL2.STATEID IN (2,4,8)
             AND SCL2.BOOK_START_TIME < params.DATETIME_before
             AND (
                 SCL2.BOOK_END_TIME IS NULL
                 OR SCL2.BOOK_END_TIME >= params.DATETIME_before)
             AND SCL2.ENTRY_START_TIME < params.DATETIME_before
 --AND ST2.ST_TYPE = 1
 AND SU2.CENTER = PARAMS.ID AND (ST2.CENTER, ST2.ID) not in (select  center, id from V_EXCLUDED_SUBSCRIPTIONS)
             AND p2.CURRENT_PERSON_CENTER = p.CURRENT_PERSON_CENTER
             AND p2.CURRENT_PERSON_ID = p.CURRENT_PERSON_ID
             AND (
                 SU2.id != SUB.id
                 OR su2.center != sub.center)
             AND (
                 SU2.END_DATE IS NULL
                 OR su2.END_DATE > sub.END_DATE) )
 group by p.center
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
                 AND SCL.ENTRY_START_TIME < PARAMS.STARTTIME ) ) t2
                  group by owner_center
 ) totaljoiners
 ON totalmembers.center = totaljoiners.Center
 GROUP BY  GROUPING SETS ((C.SHORTNAME, A.NAME, C.STARTUPDATE), ())
 ORDER BY C.SHORTNAME
