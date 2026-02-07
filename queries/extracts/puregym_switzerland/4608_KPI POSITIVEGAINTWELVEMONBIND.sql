WITH
    PARAMS AS materialized
    (SELECT
            /*+ materialize */
            ce.id AS CENTER ,
            CAST(datetolongTZ(TO_CHAR(TRUNC(currentdate , 'DDD'), 'YYYY-MM-DD HH24:MI'),
            'Europe/Zurich') AS BIGINT) AS STARTTIME ,
            CAST(datetolongTZ(TO_CHAR(TRUNC(currentdate +1, 'DDD'), 'YYYY-MM-DD HH24:MI'),
            'Europe/Zurich') AS BIGINT) AS ENDTIME,
            CAST(datetolongTZ(TO_CHAR(TRUNC(currentdate +2, 'DDD'), 'YYYY-MM-DD HH24:MI'),
            'Europe/Zurich') AS BIGINT) AS HARDCLOSETIME
        FROM
            (
                SELECT
                    CAST(:date AS DATE) AS currentdate ) t
                    cross join centers ce
                    where ce.id in (:scope)
    )
SELECT
    /*+ NO_BIND_AWARE */
    center as center,
      OWNER_CENTER||'p'||OWNER_ID as member
FROM
     (
        -- Outoing balance members
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
            AND SCL.BOOK_START_TIME < PARAMS.ENDTIME
            AND SCL.ENTRY_START_TIME < PARAMS.ENDTIME
            AND ( SCL.BOOK_END_TIME IS NULL
                OR  SCL.ENTRY_END_TIME >= PARAMS.HARDCLOSETIME
                OR  SCL.BOOK_END_TIME >= PARAMS.ENDTIME )
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
            OR  ccc.closed_datetime > params.ENDTIME)
  AND datetolongTZ(TO_CHAR(ccc.currentstep_date, 'YYYY-MM-DD HH24:MI'), 'Europe/Zurich') <= params.ENDTIME
        JOIN
            puregym_switzerland.product_and_product_group_link ppgl
        ON
            ppgl.product_center = su.subscriptiontype_center
        AND ppgl.product_id = su.subscriptiontype_id
        AND ppgl.product_group_id =  603
        WHERE
            ccc.center IS NULL -- exclude members in external debt
        EXCEPT
        -- That are not in incoming balance
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
            AND SCL.BOOK_START_TIME < PARAMS.STARTTIME
            AND SCL.ENTRY_START_TIME < PARAMS.STARTTIME
            AND ( SCL.BOOK_END_TIME IS NULL
                OR  SCL.ENTRY_END_TIME >= PARAMS.HARDCLOSETIME
                OR  SCL.BOOK_END_TIME >= PARAMS.STARTTIME )
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
            OR  ccc.closed_datetime > params.STARTTIME)
  AND datetolongTZ(TO_CHAR(ccc.currentstep_date, 'YYYY-MM-DD HH24:MI'), 'Europe/Zurich') <= params.STARTTIME
        JOIN
            puregym_switzerland.product_and_product_group_link ppgl
        ON
            ppgl.product_center = su.subscriptiontype_center
        AND ppgl.product_id = su.subscriptiontype_id
        AND ppgl.product_group_id =  603
    ) t