-- The extract is extracted from Exerp on 2026-02-08
-- Follows MEMBERSINDEBT KPI logic but checks that the debt collection step was reached on the queried date
WITH
    PARAMS AS materialized
    (
        SELECT
            /*+ materialize */
            ce.id AS CENTER ,
            CAST(datetolongTZ(TO_CHAR(TRUNC(CAST((:date) AS DATE)+1 , 'DDD'), 'YYYY-MM-DD HH24:MI'),
            'Europe/Zurich') AS BIGINT) AS DATETIME, cast(:date as date) +1 as day_date
            FROM
            centers ce
              where ce.id in (:scope)
    )
SELECT
    /*+ NO_BIND_AWARE */
    center as center,
      OWNER_CENTER||'p'||OWNER_ID as member
FROM
     (
        SELECT DISTINCT
            SU.OWNER_CENTER,
            SU.OWNER_ID, su.center
        FROM
            PARAMS
        JOIN
            STATE_CHANGE_LOG SCL
        ON
            ( SCL.CENTER = PARAMS.CENTER
                -- Time safety. We need to exclude subscriptions started in the past so they do not
                -- get
                -- into the incoming balance because they will not be in the outgoing balance of
                -- the
                -- previous day
            AND SCL.ENTRY_START_TIME < PARAMS.DATETIME
            AND SCL.BOOK_START_TIME < PARAMS.DATETIME
            AND ( SCL.BOOK_END_TIME IS NULL
                OR  SCL.BOOK_END_TIME >= PARAMS.DATETIME )
            AND SCL.ENTRY_TYPE = 2
            AND SCL.STATEID IN ( 2,
                                4,8))
        INNER JOIN
            SUBSCRIPTIONS SU
        ON
            ( SCL.CENTER = SU.CENTER
            AND SCL.ID = SU.ID
            AND SCL.ENTRY_TYPE = 2 )
        LEFT JOIN
            cashcollectioncases ccc
        ON
            ccc.personcenter = su.owner_center
        AND ccc.personid = su.owner_id
        AND ccc.missingpayment
        AND ccc.currentstep_type = 4
        AND (NOT(ccc.closed)
            OR  ccc.closed_datetime > params.datetime)
        
        WHERE
            ccc.center IS not NULL and ccc.currentstep_date = params.day_date
    ) t