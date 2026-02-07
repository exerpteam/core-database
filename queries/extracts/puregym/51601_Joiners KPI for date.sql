 WITH
     PARAMS AS
     (
         SELECT  /*+ materialize */
             CAST(datetolongTZ(TO_CHAR(TRUNC(currentdate::date , 'DDD'), 'YYYY-MM-DD HH24:MI'), 'Europe/London' ) AS BIGINT)  AS STARTTIME ,
             CAST(datetolongTZ(TO_CHAR(TRUNC(currentdate::date +1, 'DDD'), 'YYYY-MM-DD HH24:MI'), 'Europe/London') AS BIGINT) AS ENDTIME,
             CAST(datetolongTZ(TO_CHAR(TRUNC(currentdate::date +2, 'DDD'), 'YYYY-MM-DD HH24:MI'), 'Europe/London') AS BIGINT) AS HARDCLOSETIME,
             -- REJOINDURATION: in the last 365 days
             CAST(extract (epoch from interval '365 days')*1000 AS BIGINT) AS REJOINDURATION,
             -- REACTIVATEDURATION: in the last 31 days
             CAST(extract (epoch from interval '31 days')*1000 AS BIGINT) AS REINSTATEDURATION
         FROM
             (
                 SELECT
                     $$for_date$$ AS currentdate
                  ) sub
     )
     ,V_EXCLUDED_SUBSCRIPTIONS AS
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
     INCLUDED_ST AS
     (
         SELECT DISTINCT
             st1.center,
             st1.id
         FROM
             SUBSCRIPTIONTYPES st1
         CROSS JOIN
             params
         WHERE
             st1.center in ($$Scope$$)
             AND (
                 st1.center, st1.id) NOT IN
             (
                 SELECT
                     center,
                     id
                 FROM
                     V_EXCLUDED_SUBSCRIPTIONS
                 WHERE
                     center in ($$Scope$$))
     )
 SELECT
     CASE
         WHEN (p.CENTER != p.TRANSFERS_CURRENT_PRS_CENTER
                 OR p.id != p.TRANSFERS_CURRENT_PRS_ID )
         THEN
             (
                 SELECT
                     EXTERNAL_ID
                 FROM
                     PERSONS
                 WHERE
                     CENTER = p.TRANSFERS_CURRENT_PRS_CENTER
                     AND ID = p.TRANSFERS_CURRENT_PRS_ID)
         ELSE p.EXTERNAL_ID
     END AS "PERSON_ID"
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
             -- ST.ST_TYPE = 1
             --(ST.CENTER, ST.ID) not in (select /*+ materialize */ center, id from V_EXCLUDED_SUBSCRIPTIONS) -- 17/09/2015 ST-421 Changed from st type = 1
             --        AND
             SU.CENTER in ($$Scope$$)
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
             INCLUDED_ST ST
         JOIN
             SUBSCRIPTIONS SU
         ON
             SU.SUBSCRIPTIONTYPE_CENTER = ST.CENTER
             AND SU.SUBSCRIPTIONTYPE_ID = ST.ID
         WHERE
             --   ST.ST_TYPE = 1
             --         (ST.CENTER, ST.ID) not in (select /*+ materialize */ center, id from V_EXCLUDED_SUBSCRIPTIONS) -- 17/09/2015 ST-421 Changed from st type = 1
             --        AND
             SU.CENTER in ($$Scope$$)
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
                     AND SCL.ENTRY_START_TIME < PARAMS.STARTTIME ) ) ss
 LEFT JOIN
     persons p
 ON
     p.center = ss.OWNER_CENTER
     AND p.id = ss.OWNER_ID
