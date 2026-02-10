-- The extract is extracted from Exerp on 2026-02-08
-- COVID 19 task for extending paid in advance memberships.
WITH
    params AS
    (
        SELECT
            /*+ materialize */
            to_date('2020-03-21','YYYY-MM-DD')   AS StartDate,
            to_date('2020-07-24','YYYY-MM-DD')   AS EndDate,
            1                                    AS ClubIdFrom,
            10000                                AS ClubIdTo,
            'COVID-19 measures ST-11379 Advance' AS coment
        FROM
            DUAL
    )
SELECT
    b.center || 'ss' || b.id                 AS SUBSCRIPTIONID,
    TO_CHAR(b.sub_end_date + 1,'YYYY-MM-DD') AS startdate,
    (
        CASE
            WHEN b.sub_end_date <= params.EndDate
            THEN TO_CHAR((b.sub_end_date + interval '1' DAY * (b.free_theoric_length -
                b.existing_freeze_days_in_period - b.given_covid19_freeday_inperiod)) +
                (params.EndDate - b.sub_end_date), 'YYYY-MM-DD')
            ELSE TO_CHAR(b.sub_end_date + interval '1' DAY * (b.free_theoric_length -
                b.existing_freeze_days_in_period - b.given_covid19_freeday_inperiod), 'YYYY-MM-DD')
        END)                                                                            AS enddate ,
    b.free_theoric_length - b.existing_freeze_days_in_period - b.given_covid19_freeday_inperiod AS
                        FreeDaystobegiven ,
    b.sub_start_date AS sub_start_date,
    b.sub_end_date   AS sub_end_date,
    b.orig_end_date ,
    b.center ||'ss'|| b.id AS SubscriptionId,
    b.PersonId
FROM
    (
        SELECT --a.center - mod(a.center,20) as threadgroup,
            DISTINCT a.center,
            a.id,
            a.start_date AS sub_start_date,
            a.end_date   AS sub_end_date,
            a.orig_end_date,
            a.given_covid19_freeday_inperiod,
            params.coment ,
            a.PersonId ,
            -- days already given in a freeze in the period
            COALESCE(
                       (
                       SELECT
                           SUM(least(srd2.end_date,a.fullfreezeend) - greatest(srd2.start_date,
                           a.fullfreezestart) + 1)
                       FROM
                           subscription_freeze_period srd2
                       WHERE
                           srd2.subscription_center = a.center
                       AND srd2.subscription_id = a.id
                       AND srd2.state = 'ACTIVE'
                       AND srd2.start_date <= a.fullfreezeend
                       AND srd2.end_date >= a.fullfreezestart), 0) AS
            existing_freeze_days_in_period ,
            -- max theoretical days to give
            (a.fullfreezeend - a.fullfreezestart +1) AS free_theoric_length
        FROM
            (
                SELECT
                    s.center,
                    s.id,
                    s.owner_center || 'p' || s.owner_id AS PersonId,
                    s.center || 'ss' || s.id            AS SubscriptionId,
                    s.start_date,
                    s.end_date,
                    COALESCE(exist_free_days.orig_end_date, s.end_date)            AS orig_end_date,
                    least(COALESCE(exist_free_days.orig_end_date, s.end_date),params.EndDate) AS
                                                                fullfreezeend,
                    greatest(s.start_date, params.StartDate)     AS fullfreezestart,
                    COALESCE(exist_free_days.given_free_days, 0) AS given_covid19_freeday_inperiod
                FROM
                    subscriptions s
                    -- days given as COVID-19 free period and get orig_end_date
                LEFT JOIN
                    (
                        SELECT
                            s3.center,
                            s3.id,
                            (s3.end_date - interval '1' DAY * SUM(srd3.end_date - srd3.start_date +
                            1))                                      AS orig_end_date,
                            SUM(srd3.end_date - srd3.start_date + 1) AS given_free_days
                        FROM
                            subscriptions s3
                        JOIN
                            subscription_reduced_period srd3
                        ON
                            srd3.subscription_center = s3.center
                        AND srd3.subscription_id = s3.id
                        CROSS JOIN
                            params
                        WHERE
                            srd3.state = 'ACTIVE'
                        AND srd3.text = params.coment
                        GROUP BY
                            s3.center,
                            s3.id,
                            s3.end_date ) exist_free_days
                ON
                    exist_free_days.center = s.center
                AND exist_free_days.id = s.id
                CROSS JOIN
                    params
                JOIN
                    subscriptiontypes st
                ON
                    st.center = s.SUBSCRIPTIONTYPE_CENTER
                AND st.id = s.SUBSCRIPTIONTYPE_id
                AND st.st_type = 0
                JOIN
                    PRODUCTS pr
                ON
                    pr.center = st.center
                AND pr.id = st.id
                LEFT JOIN
                    subscriptions s_prev
                ON
                    s_prev.extended_to_center = s.center
                AND s_prev.extended_to_id = s.id
                AND s.start_date > params.StartDate
                WHERE
                    s.center >= params.ClubIdFrom
                AND s.center <= params.ClubIdTo
                    --AND s.center = 224
                    -- Look at only ACTIVE AS PER TODAY
                AND s.state IN (2,4,8)
                AND s.END_DATE >= PARAMS.StartDate
                AND s.START_DATE <= PARAMS.EndDate
                
                
                 AND pr.GLOBALID NOT IN ('ONE_MONTH_MEMBERSHIP')
                    /* exclude subscription extended in the free period: TODO handle manually */
                AND NOT (
                        s.state IN (2,5)
                    AND s.extended_to_center IS NOT NULL
                    AND COALESCE(exist_free_days.orig_end_date, s.end_date) <= PARAMS.EndDate)
                AND s_prev.center IS NULL
                    -- exclude subscriptions from those product groups
                AND NOT EXISTS
                    (
                        SELECT
                            1
                        FROM
                            PRODUCT_AND_PRODUCT_GROUP_LINK ppl
                        WHERE
                            ppl.product_center = st.center
                        AND ppl.product_id = st.id
                        AND ppl.PRODUCT_GROUP_ID IN (401,801,6409) ) ) a
        CROSS JOIN
            params ) b
CROSS JOIN
    params
WHERE
    (
        b.free_theoric_length - b.existing_freeze_days_in_period - b.given_covid19_freeday_inperiod
    ) > 0
    --and b.id < 10
ORDER BY
    1,2,3