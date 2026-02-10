-- The extract is extracted from Exerp on 2026-02-08
-- https://clublead.atlassian.net/browse/ES-17413
WITH PARAMS as MATERIALIZED
(
	SELECT 
	    ID,
	    datetolongTZ(TO_CHAR(TRUNC(sysdate , 'DDD'), 'YYYY-MM-DD HH24:MI'),   'Europe/London') AS DATETIME,
	    datetolongTZ(TO_CHAR(TRUNC(sysdate-1 , 'DDD'), 'YYYY-MM-DD HH24:MI'), 'Europe/London') AS DATETIME_before,
        datetolongTZ(TO_CHAR(TRUNC(sysdate-1 , 'DDD'), 'YYYY-MM-DD HH24:MI'), 'Europe/London') AS STARTTIME ,
        datetolongTZ(TO_CHAR(TRUNC(sysdate, 'DDD'), 'YYYY-MM-DD HH24:MI'),    'Europe/London') AS ENDTIME,
        datetolongTZ(TO_CHAR(TRUNC(sysdate +1, 'DDD'), 'YYYY-MM-DD HH24:MI'), 'Europe/London') AS HARDCLOSETIME
        FROM 
             CENTERS
        WHERE ID in (:scope)
    ),
    INCLUDED_ST as (
        select distinct st1.center, st1.id from 
        SUBSCRIPTIONTYPES st1
        cross join params
        where 
             st1.center = params.ID
              and (st1.center, st1.id) not in (select center,id from V_EXCLUDED_SUBSCRIPTIONS where center = params.ID)
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
MINUS
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
)
       group by owner_center