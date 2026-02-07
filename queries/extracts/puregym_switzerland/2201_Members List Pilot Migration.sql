WITH
    PARAMS AS materialized
    (
        SELECT
            /*+ materialize */
            6015 AS CENTER ,
            CAST(datetolongTZ(TO_CHAR(TRUNC(CAST($$for_date$$ AS DATE)+1 , 'DDD'),
            'YYYY-MM-DD HH24:MI'), 'Europe/Zurich') AS BIGINT) AS DATETIME
    )
SELECT
    /*+ NO_BIND_AWARE */
    OWNER_CENTER||'p'||OWNER_ID AS person_id,
    is_1_month_member,
    is_12_month_member,
    has_migrated_sub,
    subscription_count
FROM
    (
        SELECT DISTINCT
            SU.OWNER_CENTER,
            SU.OWNER_ID,
            bool_or(ppgl.product_group_id = 601 ) AS is_1_month_member,
            bool_or(ppgl.product_group_id = 602 ) AS is_12_month_member,
            bool_or(( su.creator_center = 100
        AND su.creator_id = 1)) AS has_migrated_sub,
        count(distinct su.center||'ss'||su.id) as subscription_count
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
        JOIN
            puregym_switzerland.product_and_product_group_link ppgl
        ON
            ppgl.product_center = su.subscriptiontype_center
        AND ppgl.product_id = su.subscriptiontype_id
        JOIN
            puregym_switzerland.products pr
        ON
            pr.center = su.subscriptiontype_center
        AND pr.id = su.subscriptiontype_id
            --AND ppgl.product_group_id = 601 --1 Month - Reporting
        WHERE
            ccc.center IS NULL -- exclude members in external debt
        GROUP BY
            SU.OWNER_CENTER,
            SU.OWNER_ID ) t
WHERE
    is_12_month_member
OR  is_1_month_member ;