-- The extract is extracted from Exerp on 2026-02-08
-- https://clublead.atlassian.net/issues/EC-8358
 WITH
     PARAMS AS
     (
         SELECT
            CAST(datetolongTZ(TO_CHAR(TRUNC(CAST($$from_date$$ AS DATE) , 'DDD'), 'YYYY-MM-DD HH24:MI'), 'Europe/Zurich') AS BIGINT) AS STARTTIME ,
            CAST(datetolongTZ(TO_CHAR(TRUNC(CAST($$to_date$$ AS DATE), 'DDD'), 'YYYY-MM-DD HH24:MI'), 'Europe/Zurich') AS BIGINT)    AS ENDTIME,
            CAST(datetolongTZ(TO_CHAR(TRUNC(CAST($$to_date$$ AS DATE) +1, 'DDD'), 'YYYY-MM-DD HH24:MI'), 'Europe/Zurich')  AS BIGINT) AS HARDCLOSETIME             
     )
     ,  V_EXCLUDED_SUBSCRIPTIONS AS
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
     ST AS "Leavers",
     CENTERNAME AS "Club Name"
 FROM
     (
         SELECT
             p.ZIPCODE  AS  Z,
             c.SHORTNAME AS CENTERNAME,
             COUNT(DISTINCT p.center||'p'||p.id)     AS ST
         FROM
             (
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
                 LEFT JOIN 
                     V_EXCLUDED_SUBSCRIPTIONS EX
                     ON  ST.CENTER = EX.CENTER
                         AND ST.ID = EX.ID
                 WHERE
                    EX.CENTER IS NULL
                     AND SU.CENTER in ($$scope$$)
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
                             -- Time safety. We need to exclude subscriptions
                             -- started in the past so they do
                             -- not
                             -- get
                             -- into the incoming balance because they will
                             -- not be in the outgoing balance
                             -- of
                             -- the
                             -- previous day
                             AND SCL.ENTRY_START_TIME < PARAMS.STARTTIME )
                 EXCEPT
                 -- Outoing balance members
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
                 LEFT JOIN 
                     V_EXCLUDED_SUBSCRIPTIONS EX
                     ON  ST.CENTER = EX.CENTER
                         AND ST.ID = EX.ID
                 WHERE
                     EX.CENTER IS NULL
                     AND SU.CENTER in ($$scope$$)
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
                             -- Time safety. We need to exclude subscriptions      -- started in the past so they do
                             -- not
                             -- get
                             -- into the incoming balance because they will
                             -- not be in the outgoing balance
                             -- of
                             -- the
                             -- previous day
                             AND SCL.ENTRY_START_TIME < PARAMS.ENDTIME ) ) LEAVERS
         JOIN
             PERSONS p
         ON
             p.center = leavers.owner_center
             AND p.id = leavers.owner_id
                 JOIN
             CENTERS c
         ON
             p.CENTER = c.ID
         WHERE
             p.status IN (0,2,6,9)
         GROUP BY
             p.ZIPCODE, c.SHORTNAME) t