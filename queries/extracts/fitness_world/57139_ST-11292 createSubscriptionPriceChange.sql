-- The extract is extracted from Exerp on 2026-02-08
--  
WITH
    params AS
    (
        SELECT
            /*+ materialize */
            to_date('2020-05-01','yyyy-MM-dd') AS from_date,
            to_date('2020-11-01','yyyy-MM-dd') AS to_date,
            -0.2                               AS CHANGE_BY_PERCENTAGE
        FROM
            dual
    )
    ,
    period_starts AS
    ( -- find all existing subscription price changes schedule after params.from_date. This is due
        -- to the API call cancelling future price changes
        SELECT
            /*+ materialize */
            s.center,
            s.id,
            sp.from_date,
            s.end_date   AS sub_end_date,
            s.start_date AS sub_start_date
        FROM
            subscriptions s
        CROSS JOIN
            params
        JOIN
            SUBSCRIPTION_PRICE sp
        ON
            sp.SUBSCRIPTION_CENTER = s.center
        AND sp.SUBSCRIPTION_ID = s.id
        AND (
                sp.TO_DATE IS NULL
            OR  sp.TO_DATE > params.from_date)
        AND sp.CANCELLED = 0
        JOIN
            FW.PERSON_EXT_ATTRS pea
        ON
            pea.PERSONCENTER = s.OWNER_CENTER
        AND pea.PERSONID = s.OWNER_ID
        AND pea.NAME = 'CORONACOMPSUB'
        AND pea.txtvalue = '2'
        WHERE
            s.state IN (2,4,8)
        AND s.START_DATE <= params.to_date
        AND (
                s.end_date IS NULL
            OR  s.end_date >= params.from_date)
            and s.owner_center in ($$scope$$)
    )
    ,
    all_period_starts AS
    ( --  find all unique price period start dates including params start and end dates
        -- add to_date based on next period start date
        -- params period prices are set based on existing price periods at param start and param
        -- end
        SELECT
            /*+ materialize */
            x.center,
            x.id,
            x.from_date,
            (lead(x.from_date) over (partition BY x.center,x.id ORDER BY x.from_date ASC))-1 AS
            to_date ,
            CASE
                WHEN x.from_date = params.from_date
                THEN start_sp.price
                WHEN x.from_date = params.to_date
                THEN end_sp.price
                ELSE sp.price
            END AS PRICE
        FROM
            (
                SELECT DISTINCT
                    center,
                    id,
                    from_date
                FROM
                    (
                        SELECT
                            center,
                            id,
                            period_starts.from_date
                        FROM
                            params,
                            period_starts
                        WHERE
                            (
                                period_starts.from_date < period_starts.sub_end_date
                            OR  period_starts.sub_end_date IS NULL)
                        AND (
                                period_starts.from_date >= params.from_date)
                        UNION ALL
                        SELECT
                            center,
                            id,
                            params.from_date
                        FROM
                            params,
                            period_starts
                        WHERE
                            period_starts.sub_start_date <= params.from_date
                        UNION ALL
                        SELECT
                            center,
                            id,
                            params.to_date
                        FROM
                            params,
                            period_starts
                        WHERE
                            period_starts.sub_end_date > params.to_date
                        OR  period_starts.sub_end_date IS NULL ) )x
        CROSS JOIN
            params
        LEFT JOIN
            SUBSCRIPTION_PRICE sp
        ON
            sp.SUBSCRIPTION_CENTER = x.center
        AND sp.SUBSCRIPTION_ID = x.id
        AND sp.FROM_DATE = x.from_date
        AND sp.CANCELLED = 0
        JOIN
            SUBSCRIPTION_PRICE start_sp
        ON
            start_sp.SUBSCRIPTION_CENTER = x.center
        AND start_sp.SUBSCRIPTION_ID = x.id
        AND start_sp.FROM_DATE <= params.from_date
        AND (
                start_sp.TO_DATE >= params.from_date
            OR  start_sp.to_date IS NULL)
        AND start_sp.CANCELLED = 0
        JOIN
            SUBSCRIPTION_PRICE end_sp
        ON
            end_sp.SUBSCRIPTION_CENTER = x.center
        AND end_sp.SUBSCRIPTION_ID = x.id
        AND end_sp.FROM_DATE <= params.to_date
        AND (
                end_sp.TO_DATE >= params.to_date
            OR  end_sp.to_date IS NULL)
        AND end_sp.CANCELLED = 0
    )
SELECT
    THREADGROUP,
    center,
    id,
    type,
    value,
    rounding_mode,
    binding,
    from_date,
    --to_date,
    "COMMENT"
FROM
    (
        SELECT
            FLOOR((ROW_NUMBER() OVER(ORDER BY center,ID) / 3000)) + 1 AS THREADGROUP,
            center,
            id,
            'SET_AMOUNT' AS type,
            ROUND(
                CASE -- add rebate
                    WHEN aps.from_date BETWEEN params.from_date AND params.to_date -1
                    THEN PRICE + params.CHANGE_BY_PERCENTAGE * PRICE
                    ELSE price
                END, 2)                         AS value,
            'DOWN'                              AS rounding_mode,
            'true'                              AS binding,
            TO_CHAR(aps.from_date,'yyyy-MM-dd') AS from_date,
            TO_CHAR(aps.to_date,'yyyy-MM-dd')   AS to_date,
            'ST-11292 COVID19 discount'         AS "COMMENT",
            PRICE                               AS OLD_PRICE,
            CASE
                WHEN aps.to_date IS NULL
                THEN 0
                ELSE 1
            END AS include_to_date
        FROM
            params,
            all_period_starts aps
        ORDER BY
            1,2,3)
/*WHERE
    include_to_date = 0*/