WITH
    sub_err AS
    (
        SELECT
            s.center,
            s.id,
            s.start_date,
            s.end_date,
            s.subscription_price,
            CAST(( (s.end_Date - s.start_date)+1) AS DECIMAL)             AS correct_length,
            SUM((CAST( ( (spp.to_date - spp.from_date) +1) AS DECIMAL) )) AS spp_length
        FROM
            leejam.subscriptions s
        JOIN
            leejam.subscriptionperiodparts spp
        ON
            spp.center = s.center
        AND spp.id = s.id
        AND spp.spp_state = 1
        WHERE
            s.creator_center = 100
        AND s.creator_id = 1
        AND s.end_date >= s.start_Date
        AND s.creator_center = 100
        AND s.creator_id = 1
        AND s.state IN (2,4)
        and not exists(select 1 from subscriptions ts where ts.transferred_center = s.center and ts.transferred_id = s.id)
        GROUP BY
            s.center,
            s.id,
            s.subscription_price,
            s.start_date,
            s.end_date
        HAVING
            CAST(( (s.end_Date - s.start_date)+1) AS DECIMAL) != SUM((CAST( ( (spp.to_date -
            spp.from_date) +1) AS DECIMAL) ))
    )
SELECT
    *,
    (correct_length - spp_length)                                 AS l_dist,
    sub_end_Date                                                  AS new_spp_to_date,
    sub_start_date                                                AS new_spp_from_date,
    ROUND(spp_subscription_price/(correct_length / spp_length),2)     AS new_spp_subscription_price,
    ROUND(spp_subscription_price/(correct_length / spp_length),2)    AS new_sub_subscription_price ,
    t.subscription_price - ROUND(spp_subscription_price/(correct_length / spp_length),2) AS
    price_diff
FROM
    (
        SELECT
            s.center,
            s.id,
            spp.center    AS spp_center,
            spp.id        AS spp_id,
            spp.subid     AS spp_subid,
            s.start_date  AS sub_start_date,
            s.end_Date    AS sub_end_Date,
            spp.from_Date AS spp_from_date,
            spp.to_date   AS spp_to_date,
            s.correct_length,
            s.spp_length,
            spp.subscription_price AS spp_subscription_price,
            s.subscription_price,
            CASE
                WHEN spp.from_Date = s.start_date
                THEN 'end_missing'
                WHEN spp.to_date = s.end_date
                THEN 'start_missing'
                WHEN spp.from_Date != s.start_date
                AND spp.to_date != s.end_date
                THEN 'both_missing'
            END AS err_type
            --ces.*
        FROM
            sub_err s
        JOIN
            leejam.subscriptionperiodparts spp
        ON
            spp.center = s.center
        AND spp.id = s.id
        AND spp.spp_state = 1 ) t