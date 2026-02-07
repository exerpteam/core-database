WITH
    PARAMS AS
    (
        SELECT
            /*+ materialize */
            ce.id AS CENTER ,
            CAST (datetolongTZ(TO_CHAR(CAST((:date) AS DATE)+1, 'YYYY-MM-dd HH24:MI'), COALESCE
            (ce.time_zone, co.defaulttimezone)) AS BIGINT) -1 AS DATETIME
        FROM
            centers ce
        LEFT JOIN
            countries co
        ON
            ce.country = co.id
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
            AND SCL.ENTRY_START_TIME < PARAMS.DATETIME
            AND SCL.BOOK_START_TIME < PARAMS.DATETIME
            AND ( SCL.BOOK_END_TIME IS NULL
                OR  SCL.BOOK_END_TIME >= PARAMS.DATETIME )
            AND SCL.ENTRY_TYPE = 2
            AND SCL.STATEID = 4)
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
            OR  ccc.closed_datetime > params.DATETIME)
        AND ccc.start_datetime < params.DATETIME
        JOIN
            product_and_product_group_link ppgl
        ON
            ppgl.product_center = su.subscriptiontype_center
        AND ppgl.product_id = su.subscriptiontype_id
        AND ppgl.product_group_id = 603
        WHERE
            ccc.id IS NULL ) x