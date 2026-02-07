-- This is the version from 2026-02-05
--  
WITH params AS MATERIALIZED
(
    SELECT
        $$fromdate$$ AS fromDate,
        $$todate$$ AS toDate,
        to_timestamp($$todate$$ / 1000)::date AS todayDate,
        c.id
    FROM centers c
    WHERE c.id IN (:Scope)
),
non_discount_price AS
(
        SELECT
                t.*
        FROM
        (
                SELECT
                        su.center,
                        su.id,
                        sp.price,
                        sp.from_date,
                        rank() over (partition BY su.center,su.id ORDER BY sp.from_date DESC) AS rnk
                FROM subscriptions su
                JOIN params par ON su.center = par.id
                JOIN subscription_price sp
                        ON sp.subscription_center = su.center AND sp.subscription_id = su.id
                WHERE
                        su.last_modified >= par.fromDate
                        AND su.last_modified < par.toDate
                        AND sp.cancelled = false
        ) t
        WHERE
                t.rnk=1
)
SELECT 
        DISTINCT
        np.external_id AS "EXTERNALID",
        su.center || 'ss' || su.id AS "SUBSCRIPTIONID",
        su.start_date AS "STARTDATE",
        su.end_date AS "ENDDATE",
        pr.center || 'prod' || pr.id AS "PRODUCTID",
        TO_CHAR(su.subscription_price,'FM999999990.00') AS "CURRENTPRICE",
        TO_CHAR(ROUND(ndp.price, 2), 'FM999999990.00') AS "NORMALPRICE",
        ndp.from_date AS "NORMALPRICEDATE",
        TO_CHAR(longtodateC(su.creation_time, su.center) , 'YYYY-MM-DD') AS "MEMBERSIGNUPDATE",
        TO_CHAR(ROUND(il.total_amount, 2), 'FM999999990.00') AS "PRICEJFEE",
        (CASE
                WHEN il.total_amount < il.product_normal_price
                        THEN 1
                ELSE 0
        END) AS "DISCOUNTEDJFEE",
        (CASE COALESCE(ss.price_admin_fee,0)
                WHEN 0 THEN 0
                ELSE 1
        END) AS "PAIDCHARITYDONATION",
        (CASE su.state
                WHEN 2 THEN 'ACTIVE'
                WHEN 3 THEN 'ENDED'
                WHEN 4 THEN 'FROZEN'
                WHEN 7 THEN 'WINDOW'
                WHEN 8 THEN 'CREATED'
                ELSE 'UNKNOWN'
        END) AS "STATE",
        (CASE su.sub_state
                WHEN 1 THEN 'NONE'
                WHEN 2 THEN 'AWAITING_ACTIVATION'
                WHEN 3 THEN 'UPGRADED'
                WHEN 4 THEN 'DOWNGRADED'
                WHEN 5 THEN 'EXTENDED'
                WHEN 6 THEN 'TRANSFERRED'
                WHEN 7 THEN 'REGRETTED'
                WHEN 8 THEN 'CANCELLED'
                WHEN 9 THEN 'BLOCKED'
                ELSE 'UNKNOWN'
        END) AS "SUBSTATE",
        (CASE sc.NEW_SUBSCRIPTION_CENTER||'ss'||sc.NEW_SUBSCRIPTION_ID
                WHEN 'ss' THEN NULL
                ELSE sc.NEW_SUBSCRIPTION_CENTER||'ss'||sc.NEW_SUBSCRIPTION_ID
        END) AS "NEWSUBSCRIPTIONID",
        TO_CHAR(longtodateC(su.last_modified,su.center),'YYYY-MM-DD HH24:MI:SS') AS "LASTMODIFIEDDATE"
FROM fw.persons p
JOIN params par 
        ON par.id = p.center
JOIN fw.persons np
        ON np.center = p.current_person_center AND np.id = p.current_person_id
JOIN fw.subscriptions su
        ON su.owner_center = p.center AND su.owner_id = p.id
JOIN fw.subscriptiontypes st
        ON st.center = su.subscriptiontype_center AND st.id = su.subscriptiontype_id
JOIN fw.products pr
        ON pr.center = st.center AND pr.id = st.id
LEFT JOIN fw.invoice_lines_mt il
        ON il.center = su.invoiceline_center AND il.id = su.invoiceline_id AND il.subid = su.invoiceline_subid
LEFT JOIN fw.subscription_sales ss
        ON ss.subscription_center = su.center AND ss.subscription_id = su.id
LEFT JOIN non_discount_price AS ndp
        ON ndp.center = su.center AND ndp.id = su.id
LEFT JOIN fw.subscription_change sc
        ON sc.old_subscription_center = su.center AND sc.old_subscription_id = su.id
        AND sc.new_subscription_center IS NOT NULL
        AND sc.type NOT IN ('END_DATE')
        AND par.todayDate > sc.effect_date
        AND (sc.cancel_time IS NULL OR sc.cancel_time > par.toDate)

WHERE
        su.last_modified >= par.fromDate
        AND su.last_modified < par.toDate
