-- The extract is extracted from Exerp on 2026-02-08
-- https://clublead.atlassian.net/browse/ST-6029
WITH
    sales AS
    (
        SELECT DISTINCT
            CASE
                WHEN first_value( TRUNC(longToDate(act.ENTRY_START_TIME)) ) over
                    ( partition BY p.CENTER,p.ID ORDER BY act.ENTRY_TYPE ASC ) < ss.SALES_DATE
                THEN 'OLD MEMBER'
                ELSE 'NEW MEMBER'
            END AS MEMBER_TYPE,
            p.CENTER || 'p' || p.ID "Member id",
            p.SEX                                                "Sex",
            floor(months_between(TRUNC(current_timestamp),p.BIRTHDATE)/12) "Age",
            p.ZIPCODE "Postal number",
            p.CITY "City",
            ss.SUBSCRIPTION_CENTER "Signup club",
            ss.SALES_DATE "Signup date",
            CASE
                WHEN ( ss.EMPLOYEE_CENTER,ss.EMPLOYEE_ID ) IN ((114,813))
                THEN 'API'
                ELSE 'Club'
            END AS "Signup method",
            CASE WHEN scl.CENTER IS NOT NULL THEN 0 ELSE 1 END "New member",
            prod.NAME "Subscription name",
            ss.price_new joining_fee,
            ss.PRICE_PERIOD "Subscription price",
			COALESCE(ss.PRICE_INITIAL,0) + COALESCE(ss.PRICE_PRORATA,0) AS upfront_payment
        FROM
            (
                SELECT
                    /*+materialize*/
                    (TRUNC(current_timestamp)-$$offset$$) AS FROMDATE,
                    TRUNC(current_timestamp)              AS TODATE
                 ) params ,
            SUBSCRIPTION_SALES ss
        JOIN
            PRODUCTS prod
        ON
            prod.CENTER = ss.SUBSCRIPTION_TYPE_CENTER
        AND prod.ID = ss.SUBSCRIPTION_TYPE_ID
        JOIN
            product_and_product_group_link pg_link
        ON
            pg_link.product_center = prod.center
        AND pg_link.product_id = prod.id
        JOIN
            product_group pg
        ON
            pg.id = pg_link.product_group_id
        OR  pg.top_node_id = pg_link.product_group_id
        JOIN
            PERSONS p
        ON
            p.CENTER = ss.OWNER_CENTER
        AND p.ID = ss.OWNER_ID
        LEFT JOIN
            STATE_CHANGE_LOG scl
        ON
            scl.CENTER = p.CENTER
        AND scl.ID = p.ID
        AND scl.STATEID = 1
        AND scl.ENTRY_TYPE = 1
        AND scl.ENTRY_END_TIME IS NOT NULL
        LEFT JOIN
            PERSONS oldp
        ON
            oldp.CURRENT_PERSON_CENTER = p.CENTER
        AND oldp.CURRENT_PERSON_ID = p.ID
        LEFT JOIN
            STATE_CHANGE_LOG act
        ON
            act.CENTER = oldp.CENTER
        AND act.ID = oldp.ID
        AND act.ENTRY_TYPE = 1
        AND act.STATEID = 1
        WHERE
            ss.SALES_DATE BETWEEN params.fromdate AND params.todate
        AND ss.SUBSCRIPTION_CENTER IN ($$scope$$)
        AND ss.TYPE = 1
        AND pg.name IN ('# Annalect pricing')
    )
    (
        SELECT
            TO_CHAR(("Signup date"), 'YYYY-MM-DD')        AS "date_pricing",
            'joining fee'             					  AS "type_pricing",
            TO_CHAR(ROUND(AVG(joining_fee),2),'FM990.00') AS "value_pricing",
            'dkk'                     AS "currency_pricing"
        FROM
            sales
        GROUP BY
            "Signup date"
        --UNION ALL
        --SELECT
        --    "Signup date"                      AS "date_pricing",
        --    'subscription fee'                 AS "type_pricing",
        --   TO_CHAR( ROUND(AVG("Subscription price"),2),'FM990.00') AS "value_pricing",
        --    'dkk'                              AS "currency_pricing"
        --FROM
        --    sales
        --GROUP BY
        --    "Signup date"
		UNION ALL
        SELECT
            TO_CHAR(("Signup date"), 'YYYY-MM-DD')                      AS "date_pricing",
            'upfront payment'                 AS "type_pricing",
           TO_CHAR( ROUND(AVG(upfront_payment),2),'FM990.00') AS "value_pricing",
            'dkk'                              AS "currency_pricing"
        FROM
            sales
        GROUP BY
            "Signup date")
ORDER BY
    "date_pricing" ASC,
    "type_pricing" ASC
