WITH
    params AS Materialized
    (
        SELECT
            c.id,
            datetolongtz(TO_CHAR(TO_DATE(getCenterTime(c.id),'YYYY-MM-DD') - interval '5 days',
            'YYYY-MM-DD HH24:MI'), c.time_zone) AS FROMDATE,
            datetolongtz(TO_CHAR(TO_DATE(getCenterTime(c.id),'YYYY-MM-DD') + interval '1 days',
            'YYYY-MM-DD HH24:MI'), c.time_zone) AS TODATE
        FROM
            centers c
        WHERE
            id IN ($$scope$$)
    )
SELECT
    biview.*
FROM
    (
        SELECT
            ((ss.subscription_center || 'ss'::text) || ss.subscription_id) AS subscription_id,
            ss.subscription_center,
            ((ss.subscription_type_center || 'prod'::text) || ss.subscription_type_id) AS
            product_id,
            CASE ss.type
                WHEN 1
                THEN 'NEW'::text
                WHEN 2
                THEN 'EXTENSION'::text
                WHEN 3
                THEN 'CHANGE'::text
                ELSE 'UNKNOWN'::text
            END                                                                    AS sales_type,
            TO_CHAR((ss.sales_date)::TIMESTAMP WITH TIME zone, 'YYYY-MM-DD'::text) AS sales_date,
            TO_CHAR((ss.start_date)::TIMESTAMP WITH TIME zone, 'YYYY-MM-DD'::text) AS start_date,
            TO_CHAR((ss.end_date)::TIMESTAMP WITH TIME zone, 'YYYY-MM-DD'::text)   AS end_date,
            cp.external_id                                                         AS
                                                      sales_person_id,
            (ss.price_new + ss.price_new_discount)              AS jf_normal_price,
            ss.price_new_discount                               AS jf_discount,
            ss.price_new                                        AS jf_price,
            ss.price_new_sponsored                              AS jf_sponsored,
            (ss.price_new - ss.price_new_sponsored)             AS jf_member,
            (ss.price_prorata + ss.price_prorata_discount)      AS pro_rata_period_normal_price,
            ss.price_prorata_discount                           AS prorata_period_discount,
            ss.price_prorata                                    AS prorata_period_price,
            ss.price_prorata_sponsored                          AS prorata_period_sponsored,
            (ss.price_prorata - ss.price_prorata_sponsored)     AS prorata_period_member,
            (ss.price_initial + ss.price_initial_discount)      AS init_period_normal_price,
            ss.price_initial_discount                           AS init_period_discount,
            ss.price_initial                                    AS init_period_price,
            ss.price_initial_sponsored                          AS init_period_sponsored,
            (ss.price_initial - ss.price_initial_sponsored)     AS init_period_member,
            (ss.price_admin_fee + ss.price_admin_fee_discount)  AS admin_fee_normal_price,
            ss.price_admin_fee_discount                         AS admin_fee_discount,
            ss.price_admin_fee                                  AS admin_fee_price,
            ss.price_admin_fee_sponsored                        AS admin_fee_sponsored,
            (ss.price_admin_fee - ss.price_admin_fee_sponsored) AS admin_fee_member,
            ss.binding_days,
            s.creation_time AS ets
        FROM
            ((((subscription_sales ss
        JOIN
            subscriptions s
        ON
            (((
                        s.center = ss.subscription_center)
                AND (
                        s.id = ss.subscription_id))))
        JOIN
            employees emp
        ON
            (((
                        emp.center = ss.employee_center)
                AND (
                        emp.id = ss.employee_id))))
        JOIN
            persons p
        ON
            (((
                        p.center = emp.personcenter)
                AND (
                        p.id = emp.personid))))
        JOIN
            persons cp
        ON
            (((
                        cp.center = p.current_person_center)
                AND (
                        cp.id = p.current_person_id)))) ) biview
JOIN
    PARAMS
ON
    params.id = CAST(biview."subscription_center" AS INT)
WHERE
    biview."ets" >= PARAMS.FROMDATE
AND biview."ets" < PARAMS.TODATE