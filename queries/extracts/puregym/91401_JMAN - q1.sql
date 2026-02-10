-- The extract is extracted from Exerp on 2026-02-08
--  
WITH
PARAMS AS
     (
         SELECT 
             CAST(datetolongTZ(TO_CHAR(TRUNC(currentdate , 'DDD'), 'YYYY-MM-DD HH24:MI'), 'Europe/London') AS BIGINT) AS STARTTIME ,
             CAST(datetolongTZ(TO_CHAR(TRUNC(currentdate +1, 'DDD'), 'YYYY-MM-DD HH24:MI'), 'Europe/London') AS BIGINT) AS ENDTIME,
             CAST(datetolongTZ(TO_CHAR(TRUNC(currentdate +2, 'DDD'), 'YYYY-MM-DD HH24:MI'), 'Europe/London') AS BIGINT) AS HARDCLOSETIME
         FROM
             (
                 SELECT
                     CAST('2025-05-08' AS DATE) AS currentdate
                 ) t
     )

SELECT

  case when  ( SCL.ENTRY_TYPE = 2
                 AND SCL.BOOK_START_TIME < PARAMS.ENDTIME
                 AND (
                         SCL.BOOK_END_TIME IS NULL
                     OR  SCL.ENTRY_END_TIME >= PARAMS.HARDCLOSETIME
                     OR  SCL.BOOK_END_TIME >= PARAMS.ENDTIME )
                 AND SCL.ENTRY_TYPE = 2
                 AND SCL.STATEID IN ( 2,
                                     4,8)
                 AND SCL.ENTRY_START_TIME < PARAMS.ENDTIME)
  then 1 
  else 0
  end as include_flag
                     
  , case when (SCL.ENTRY_TYPE = 2
                 and SCL.BOOK_START_TIME < PARAMS.STARTTIME
                 AND (
                         SCL.BOOK_END_TIME IS NULL
                     OR  SCL.ENTRY_END_TIME >= PARAMS.HARDCLOSETIME
                     OR  SCL.BOOK_END_TIME >= PARAMS.STARTTIME )
                 AND SCL.ENTRY_TYPE = 2
                 AND SCL.STATEID IN ( 2,
                                     4,8)
                 AND SCL.ENTRY_START_TIME < PARAMS.STARTTIME )
  then 1 
  else 0
  end as exclude_flag

  , *
  FROM STATE_CHANGE_LOG SCL
  JOIN
    SUBSCRIPTIONS SU
  ON
    SCL.CENTER = SU.CENTER
    AND SCL.ID = SU.ID
  JOIN SUBSCRIPTIONTYPES ST
    ON SU.SUBSCRIPTIONTYPE_CENTER = ST.CENTER
         AND SU.SUBSCRIPTIONTYPE_ID = ST.ID
  JOIN PARAMS 
    ON 1=1
  WHERE
    SU.owner_id = 15608494