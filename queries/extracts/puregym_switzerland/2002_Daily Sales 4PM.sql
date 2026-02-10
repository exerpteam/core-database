-- The extract is extracted from Exerp on 2026-02-08
--  
WITH
    PARAMS AS materialized
    (
        SELECT
            /*+ materialize */
            CAST(datetolongTZ(TO_CHAR(TRUNC(currentdate , 'DDD'), 'YYYY-MM-DD HH24:MI'),
            'Europe/Zurich') AS BIGINT) AS STARTTIME ,
            CAST(datetolongTZ(TO_CHAR(TRUNC(currentdate +1, 'DDD'), 'YYYY-MM-DD HH24:MI'),
            'Europe/Zurich') AS BIGINT) AS ENDTIME,
            CAST(datetolongTZ(TO_CHAR(TRUNC(currentdate +2, 'DDD'), 'YYYY-MM-DD HH24:MI'),
            'Europe/Zurich') AS BIGINT) AS HARDCLOSETIME,
            currentdate
        FROM
            (
                SELECT
                    CAST(CURRENT_DATE AS DATE) AS currentdate ) t
    )
SELECT
    CASE
        WHEN c.NAME IS NULL
        THEN ' Grand Total'
        ELSE c.name
    END AS "Center Name",
    CASE
        WHEN c.STARTUPDATE>CURRENT_TIMESTAMP
        THEN 'Pre-Join'
        WHEN C.STARTUPDATE IS NULL
        THEN NULL
        ELSE 'Open'
    END    AS "Center Status",
    a.name AS "Region",
    SUM(COALESCE(totaljoiners.Joiner_Count,0)) "Today's Joiners 4pm",
    SUM(COALESCE(leavers.Leavers_for_day,0)) "Today's Leavers 4pm"
FROM
    CENTERS c
JOIN
    AREA_CENTERS AC
ON
    c.ID = AC.CENTER
JOIN
    AREAS A
ON
    A.ID = AC.AREA
AND A.PARENT = 2
LEFT JOIN
    (
        SELECT
            OWNER_CENTER AS Center,
            COUNT(*)     AS Leavers_for_day
        FROM
            (
                -- That are not in incoming balance
                SELECT DISTINCT
                    SU.OWNER_CENTER,
                    SU.OWNER_ID,  ppgl.product_group_id IN (601),ppgl.product_group_id IN (602),ppgl.product_group_id IN (603)
                FROM
                    PARAMS
                JOIN
                    STATE_CHANGE_LOG SCL
                ON
                    (
                        -- Time safety. We need to exclude subscriptions started in the
                        -- past so they do not
                        -- get
                        -- into the incoming balance because they will not be in the
                        -- outgoing balance of
                        -- the
                        -- previous day
                        SCL.BOOK_START_TIME < PARAMS.STARTTIME
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
                    and ccc.currentstep_date <= params.currentdate
                JOIN
                    puregym_switzerland.product_and_product_group_link ppgl
                ON
                    ppgl.product_center = su.subscriptiontype_center
                AND ppgl.product_id = su.subscriptiontype_id
                AND ppgl.product_group_id IN (601,602,603) --1 Month - Reporting
                WHERE
                    ccc.center IS NULL
                EXCEPT
                -- Outoing balance members
                SELECT DISTINCT
                    SU.OWNER_CENTER,
                    SU.OWNER_ID,  ppgl.product_group_id IN (601),ppgl.product_group_id IN (602),ppgl.product_group_id IN (603)
                FROM
                    PARAMS
                JOIN
                    STATE_CHANGE_LOG SCL
                ON
                    (
                        -- Time safety. We need to exclude subscriptions started in the
                        -- past so they do not
                        -- get
                        -- into the incoming balance because they will not be in the
                        -- outgoing balance of
                        -- the
                        -- previous day
                        SCL.BOOK_START_TIME < PARAMS.ENDTIME
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
                    and ccc.currentstep_date <= params.currentdate
                JOIN
                    puregym_switzerland.product_and_product_group_link ppgl
                ON
                    ppgl.product_center = su.subscriptiontype_center
                AND ppgl.product_id = su.subscriptiontype_id
                AND ppgl.product_group_id IN (601,602,603) --1 Month - Reporting
                WHERE
                    ccc.center IS NULL -- exclude members in external debt
            ) t2
        GROUP BY
            owner_center ) leavers
ON
    c.id = leavers.center
LEFT JOIN
    (
        SELECT
            OWNER_CENTER AS Center,
            COUNT(*)     AS Joiner_Count
        FROM
            (
                -- Outoing balance members
                SELECT DISTINCT
                    SU.OWNER_CENTER,
                    SU.OWNER_ID,  ppgl.product_group_id IN (601),ppgl.product_group_id IN (602),ppgl.product_group_id IN (603)
                FROM
                    PARAMS
                JOIN
                    STATE_CHANGE_LOG SCL
                ON
                    (
                        -- Time safety. We need to exclude subscriptions started in the
                        -- past so they do not
                        -- get
                        -- into the incoming balance because they will not be in the
                        -- outgoing balance of
                        -- the
                        -- previous day
                        SCL.BOOK_START_TIME < PARAMS.ENDTIME
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
                    and ccc.currentstep_date <= params.currentdate
                JOIN
                    puregym_switzerland.product_and_product_group_link ppgl
                ON
                    ppgl.product_center = su.subscriptiontype_center
                AND ppgl.product_id = su.subscriptiontype_id
                AND ppgl.product_group_id IN (601,602,603) --1 Month - Reporting
                WHERE
                    ccc.center IS NULL -- exclude members in external debt
                EXCEPT
                -- That are not in incoming balance
                SELECT DISTINCT
                    SU.OWNER_CENTER,
                    SU.OWNER_ID,  ppgl.product_group_id IN (601),ppgl.product_group_id IN (602),ppgl.product_group_id IN (603)
                FROM
                    PARAMS
                JOIN
                    STATE_CHANGE_LOG SCL
                ON
                    (
                        -- Time safety. We need to exclude subscriptions started in the
                        -- past so they do not
                        -- get
                        -- into the incoming balance because they will not be in the
                        -- outgoing balance of
                        -- the
                        -- previous day
                        SCL.BOOK_START_TIME < PARAMS.STARTTIME
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
                    and ccc.currentstep_date <= params.currentdate
                JOIN
                    puregym_switzerland.product_and_product_group_link ppgl
                ON
                    ppgl.product_center = su.subscriptiontype_center
                AND ppgl.product_id = su.subscriptiontype_id
                AND ppgl.product_group_id IN (601,602,603) --1 Month - Reporting
                WHERE
                    ccc.center IS NULL
            ) t2
        GROUP BY
            owner_center ) totaljoiners
ON
  c.id = totaljoiners.Center
GROUP BY
    GROUPING SETS ((C.name, A.NAME, C.STARTUPDATE), ())
ORDER BY
    C.name