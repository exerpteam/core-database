-- The extract is extracted from Exerp on 2026-02-08
--  

SELECT
    fullprice.pid,
    fullprice.SUBSCRIPTION_CENTER,
    fullprice.SUBSCRIPTION_ID,
    fullprice.id   addon_id,
    fullprice.name addon_name,
    (fullprice.START_PERIOD_PART_OF_MONTH + fullprice.MONTH_IN_THE_MIDDLE +
    fullprice.END_PERIOD_PART_OF_MONTH)*fullprice.quantity*fullprice.price total_for_period,
    COALESCE(ROUND(cast(frz.total_for_period as numeric),2),0)                                reduced_amount,
    (COALESCE(fullprice.START_PERIOD_PART_OF_MONTH,0) + COALESCE(fullprice.MONTH_IN_THE_MIDDLE,0) + COALESCE
    (fullprice.END_PERIOD_PART_OF_MONTH,0))*fullprice.quantity*fullprice.price - ROUND(COALESCE
    (cast(frz.total_for_period as numeric),0),2) to_be_invoiced
    
FROM
    (
        SELECT
            srp.id,
            srp.START_DATE,
            srp.END_DATE - srp.START_DATE + 1                                 days,
            extract('day' from least(srp.END_DATE,DATE_TRUNC('month', srp.START_DATE) + interval '1 month - 1 day') - srp.START_DATE + interval '1 day') days_in_start_month,
            CASE
                WHEN srp.END_DATE > DATE_TRUNC('month', srp.START_DATE) + interval '1 month - 1 day'
                THEN extract('day' from srp.END_DATE - greatest(srp.START_DATE,DATE_TRUNC('month', srp.END_DATE)) + interval '1 day')
                ELSE 0
            END AS days_in_end_month,
            extract('day' from (least(srp.END_DATE,DATE_TRUNC('month', srp.START_DATE) + interval '1 month - 1 day') - srp.START_DATE + interval '1 day') / (extract('day' from (DATE_TRUNC('month', srp.START_DATE) + interval '1 month - 1 day')))) start_period_part_of_month,
            CASE
                 WHEN months_between(cast(DATE_TRUNC('month',srp.END_DATE) as date),cast(DATE_TRUNC('month',srp.START_DATE)+ interval '1 month' as date)) > 0
                 THEN months_between(cast(DATE_TRUNC('month',srp.END_DATE) as date),cast(DATE_TRUNC('month',srp.START_DATE)+ interval '1 month' as date))
                 ELSE 0
             END AS month_in_the_middle,
            CASE
                WHEN srp.END_DATE > DATE_TRUNC('month', srp.START_DATE) + interval '1 month - 1 day'
                THEN extract('day' from (srp.END_DATE - greatest(srp.START_DATE,DATE_TRUNC('month', srp.END_DATE)) + interval '1 day') /
                    (extract('day' from DATE_TRUNC('month', srp.END_DATE) + interval '1 month - 1 day')))
                ELSE 0
            END AS end_period_part_of_month,
            srp.price,
            srp.quantity,
            srp.SUBSCRIPTION_CENTER,
            srp.SUBSCRIPTION_ID,
            srp.pid,
            srp.name
        FROM
            (
                SELECT
                    greatest(cast(:fromDate as Date),sa.START_DATE)                       START_DATE,
                    least(cast(:toDate as Date),COALESCE(sa.END_DATE,TO_DATE('9999', 'yyyy'))) END_DATE,
                    prod.PRICE,
                    sa.QUANTITY,
                    sa.ID,
                    sa.SUBSCRIPTION_CENTER,
                    sa.SUBSCRIPTION_ID,
                    s.OWNER_CENTER || 'p' || s.OWNER_ID pid,
                    prod.NAME
                FROM
                    HP.SUBSCRIPTION_ADDON sa
                JOIN
                    HP.SUBSCRIPTIONS s
                ON
                    s.CENTER = sa.SUBSCRIPTION_CENTER
                AND s.ID = sa.SUBSCRIPTION_ID
                JOIN
                    HP.MASTERPRODUCTREGISTER mpr
                ON
                    mpr.id = sa.ADDON_PRODUCT_ID
                JOIN
                    HP.PRODUCTS prod
                ON
                    prod.GLOBALID = mpr.GLOBALID
                AND prod.CENTER = sa.SUBSCRIPTION_CENTER
                WHERE
                    sa.CANCELLED != true
                AND (
                        sa.END_DATE >= cast(:fromDate as Date)
                    OR  sa.END_DATE IS NULL)
                AND sa.START_DATE <= cast(:toDate as Date) ) srp
        WHERE
            srp.SUBSCRIPTION_CENTER IN (:scope) ) fullprice
LEFT JOIN
    (
        SELECT
            redPrice.id,
            SUM((redPrice.START_PERIOD_PART_OF_MONTH + redPrice.MONTH_IN_THE_MIDDLE +
            redPrice.END_PERIOD_PART_OF_MONTH)*redPrice.quantity*redPrice.price) total_for_period
        FROM
            (
                SELECT
                    srp.PRICE,
                    srp.QUANTITY,
                    srp.ID,
                    srp.START_DATE,
                    srp.END_DATE - srp.START_DATE + 1 days,
                    least(srp.END_DATE,DATE_TRUNC('month', srp.START_DATE) + interval '1 month - 1 day') - srp.START_DATE + interval '1 day'
                    days_in_start_month,
                    CASE
                        WHEN srp.END_DATE > DATE_TRUNC('month', srp.START_DATE) + interval '1 month - 1 day'
                        THEN extract('day' from srp.END_DATE - greatest(srp.START_DATE,DATE_TRUNC('month', srp.END_DATE)) + interval '1 day')
                        ELSE 0
                    END AS days_in_end_month,
                    extract('day' from (least(srp.END_DATE,DATE_TRUNC('month', srp.START_DATE) + interval '1 month - 1 day') - srp.START_DATE + interval '1 day')) /
                    (extract('day' from DATE_TRUNC('month', srp.START_DATE) + interval '1 month - 1 day')) start_period_part_of_month,
                    greatest(coalesce(extract('year' from age(DATE_TRUNC('month', srp.END_DATE),DATE_TRUNC('month', srp.START_DATE) + interval '1 month'))*12+extract('month' from age(DATE_TRUNC('month', srp.END_DATE),DATE_TRUNC('month', srp.START_DATE) + interval '1 month')),0),0) AS month_in_the_middle,
                    CASE
                        WHEN srp.END_DATE > DATE_TRUNC('month', srp.START_DATE) + interval '1 month - 1 day'
                        THEN extract('day' from (srp.END_DATE - greatest(srp.START_DATE,DATE_TRUNC('month', srp.END_DATE))
                            + interval '1 day')) / (extract('day' from DATE_TRUNC('month', srp.END_DATE) + interval '1 month - 1 day'))
                        ELSE 0
                    END AS end_period_part_of_month
                FROM
                    (
                        SELECT
                            p.SUBSCRIPTION_CENTER,
                            p.SUBSCRIPTION_ID,
                            greatest(p.START_DATE,cast(:fromDate as Date),sa.START_DATE) START_DATE,
                            least(p.END_DATE,cast(:toDate as Date),COALESCE(sa.END_DATE,TO_DATE('9999', 'yyyy')))
                            END_DATE,
                            p.STATE,
                            prod.PRICE,
                            sa.QUANTITY,
                            sa.ID
                        FROM
                            HP.SUBSCRIPTION_REDUCED_PERIOD p
                        JOIN
                            HP.SUBSCRIPTION_ADDON sa
                        ON
                            sa.SUBSCRIPTION_CENTER = p.SUBSCRIPTION_CENTER
                        AND sa.SUBSCRIPTION_ID = p.SUBSCRIPTION_ID
                        JOIN
                            HP.MASTERPRODUCTREGISTER mpr
                        ON
                            mpr.id = sa.ADDON_PRODUCT_ID
                        JOIN
                            HP.PRODUCTS prod
                        ON
                            prod.GLOBALID = mpr.GLOBALID
                        AND prod.CENTER = sa.SUBSCRIPTION_CENTER
                        WHERE
                            p.END_DATE >= cast(:fromDate as Date)
                        AND p.START_DATE <= cast(:toDate as Date) ) srp
                WHERE
                    srp.SUBSCRIPTION_CENTER IN (:scope)
                AND srp.STATE = 'ACTIVE' ) redPrice
        GROUP BY
            redPrice.id ) frz
ON
    frz.id = fullPrice.id