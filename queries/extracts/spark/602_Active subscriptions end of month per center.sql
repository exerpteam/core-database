WITH
    params AS MATERIALIZED
    (
        SELECT
            DATE_TRUNC('month', TO_DATE(getcentertime(c.id), 'YYYY-MM-DD')) + interval '1 month' -
            interval '1 day' - (dates* interval '1 month') AS cut_date,
            c.id                                           AS center_id,
            c.name                                         AS center_name
        FROM
            generate_series(0,:months,1) dates,
            centers c
    )
SELECT
    t.center_id                       AS "Center ID",
    t.center_name                     AS "Center name",
    TO_CHAR(t.cut_date, 'YYYY Month') AS "Month",
    COUNT(
        CASE
            WHEN t.sub_type = 'Single access'
            THEN 1
            ELSE NULL
        END) AS "Active Single access",
    COUNT(
        CASE
            WHEN t.sub_type = 'Dual access'
            THEN 1
            ELSE NULL
        END) AS "Active Dual access",
    COUNT(
        CASE
            WHEN t.sub_type = 'All access'
            THEN 1
            ELSE NULL
        END) AS "Active All access",
    COUNT(*) AS "Total active subscriptions"
FROM
    (
        SELECT
            par.cut_date,
            pg.name AS sub_type,
            par.center_id,
            par.center_name
        FROM
            subscriptions s
        JOIN
            params par
        ON
            par.center_id = s.center
        AND s.start_date <= par.cut_date
        AND (
                s.end_date IS NULL
            OR  s.end_date >= par.cut_date)
        JOIN
            subscriptiontypes st
        ON
            st.center = s.subscriptiontype_center
        AND st.id = s.subscriptiontype_id
        JOIN
            products pr
        ON
            pr.center = st.center
        AND pr.id = st.id
        JOIN
            product_and_product_group_link prgl
        ON
            prgl.product_center = pr.center
        AND prgl.product_id = pr.id
        JOIN
            product_group pg
        ON
            pg.id = prgl.product_group_id
        WHERE
            pg.id IN (201,
                      202,
                      203)
        AND s.center IN (:scope)
        ) t
GROUP BY
    t.cut_date,
    t.center_id,
    t.center_name
ORDER BY
    t.cut_date,
	t.center_id