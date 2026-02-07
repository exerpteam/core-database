 WITH PARAMS as  materialized
 (
         SELECT 
             CAST(datetolongTZ(TO_CHAR(TRUNC(CAST($$For_Date$$ AS DATE) , 'DDD'), 'YYYY-MM-DD HH24:MI'), 'Europe/London')  AS BIGINT) AS STARTTIME ,
             CAST(datetolongTZ(TO_CHAR(TRUNC(CAST($$For_Date$$ AS DATE)+1, 'DDD'), 'YYYY-MM-DD HH24:MI'), 'Europe/London')  AS BIGINT) AS ENDTIME,
             CAST(datetolongTZ(TO_CHAR(TRUNC(CAST($$For_Date$$ AS DATE) +2, 'DDD'), 'YYYY-MM-DD HH24:MI'), 'Europe/London')  AS BIGINT) AS HARDCLOSETIME
         
     ) ,
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
                  st1.center in ($$Scope$$)
                 and (st1.center, st1.id) not in (select center,id from V_EXCLUDED_SUBSCRIPTIONS where center in ($$Scope$$))
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
             (
                 SCL.CENTER in ($$Scope$$)
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
             AND (ST.CENTER, ST.ID) not in (select center, id from V_EXCLUDED_SUBSCRIPTIONS where center in ($$Scope$$))
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
                 SCL.CENTER in ($$Scope$$)
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
             AND (ST.CENTER, ST.ID) not in (select center, id from V_EXCLUDED_SUBSCRIPTIONS where center in ($$Scope$$))
      )
 ) t
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
