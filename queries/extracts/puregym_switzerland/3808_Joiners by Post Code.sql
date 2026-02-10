-- The extract is extracted from Exerp on 2026-02-08
-- https://clublead.atlassian.net/issues/EC-8358
 WITH
     PARAMS AS Materialized
     (
        SELECT 
            id                                                                                  AS center,
            CAST(datetolongTZ(TO_CHAR(TRUNC(CAST($$from_date$$ AS DATE) , 'DDD'), 'YYYY-MM-DD HH24:MI'), 'Europe/Zurich') AS BIGINT) AS STARTTIME ,
            CAST(datetolongTZ(TO_CHAR(TRUNC(CAST($$to_date$$ AS DATE), 'DDD'), 'YYYY-MM-DD HH24:MI'), 'Europe/Zurich') AS BIGINT)    AS ENDTIME,
            CAST(datetolongTZ(TO_CHAR(TRUNC(CAST($$to_date$$ AS DATE) +1, 'DDD'), 'YYYY-MM-DD HH24:MI'), 'Europe/Zurich')  AS BIGINT) AS HARDCLOSETIME
        FROM
            centers
        where id in ($$scope$$) 
     ),
    V_EXCLUDED_SUBSCRIPTIONS AS Materialized
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
     Z  AS "Post Code",
     ST AS "Joiners",
     CENTERNAME AS "Club Name"
 FROM
     (
         SELECT
             p.ZIPCODE  AS  Z,
             c.SHORTNAME AS CENTERNAME,
             COUNT(DISTINCT p.center||'p'||p.id)     AS ST
          FROM
             (
                 -- Outgoing balance members
                 SELECT DISTINCT
                     SU.OWNER_CENTER,
                     SU.OWNER_ID
                 FROM
                     PARAMS,
                     SUBSCRIPTIONTYPES ST
                 JOIN
                     SUBSCRIPTIONS SU
                 ON
                     SU.SUBSCRIPTIONTYPE_CENTER = ST.CENTER
                     AND SU.SUBSCRIPTIONTYPE_ID = ST.ID
                 WHERE
                     (ST.CENTER, ST.ID) not in (select center, id from V_EXCLUDED_SUBSCRIPTIONS)
                     AND SU.CENTER = PARAMS.CENTER
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
                                 OR SCL.ENTRY_END_TIME >= PARAMS.HARDCLOSETIME
                                 OR SCL.BOOK_END_TIME >= PARAMS.ENDTIME )
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
                     SUBSCRIPTIONTYPES ST
                 JOIN
                     SUBSCRIPTIONS SU
                 ON
                     SU.SUBSCRIPTIONTYPE_CENTER = ST.CENTER
                     AND SU.SUBSCRIPTIONTYPE_ID = ST.ID
                 WHERE
                     (ST.CENTER, ST.ID) not in (select center, id from V_EXCLUDED_SUBSCRIPTIONS)
                     AND SU.CENTER = PARAMS.CENTER
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
                                 OR SCL.ENTRY_END_TIME >= PARAMS.HARDCLOSETIME
                                 OR SCL.BOOK_END_TIME >= PARAMS.STARTTIME )
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
                             AND SCL.ENTRY_START_TIME < PARAMS.STARTTIME ) ) JOINERS
         JOIN
             PERSONS p
         ON
             p.center = JOINERS.owner_center
             AND p.id = JOINERS.owner_id
                 JOIN
             CENTERS c
         ON
             p.CENTER = c.ID
         WHERE
             p.status IN (1,3)
         GROUP BY
             p.ZIPCODE, c.SHORTNAME) t
