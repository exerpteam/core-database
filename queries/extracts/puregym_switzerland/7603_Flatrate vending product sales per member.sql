-- The extract is extracted from Exerp on 2026-02-08
--  
WITH
    params AS MATERIALIZED
    (   SELECT
            CAST(datetolongC(TO_CHAR(TO_DATE((:fromDate), 'YYYY-MM-DD'), 'YYYY-MM-DD'), c.id) AS
            BIGINT) AS fromDate,
            CAST(datetolongC(TO_CHAR(TO_DATE((:toDate), 'YYYY-MM-DD')+interval '1 day',
            'YYYY-MM-DD'), c.id) AS BIGINT)-1 AS toDate,
            c.id                              AS centerId
        FROM
            centers c
        WHERE
            c.id IN (:scope)
    )
SELECT
    "Timestamp",
    "Center",
    "Member ID",
    "Member External ID",
    sub.name           AS "Subscription",
    sub_add.addon_name AS "Add-on",
    "Product sold",
	"Cost Price",
    "Paid",
    t.cutdate
FROM
    (   SELECT
            TO_CHAR(longtodateC(inv.trans_time, inv.center), 'DD/MM/YYYY HH24:MI') AS "Timestamp",
            inv.center                                                             AS "Center",
            p.center ||'p'|| p.id                                                  AS "Member ID",
            p.external_id                                                          AS
            "Member External ID" ,
            pr.name           AS "Product sold",
			pr.COST_PRICE  		  AS "Cost Price",
            invl.total_amount AS "Paid",
            TO_DATE(TO_CHAR(longtodateC(inv.trans_time, inv.center), 'YYYY-MM-DD'), 'YYYY-MM-DD')
            AS cutdate,
            p.center,
            p.id
        FROM
            invoices inv
        JOIN
            params par
        ON
            par.centerId = inv.center
        JOIN
            puregym_switzerland.cashregisters cr
        ON
            cr.center = inv.cashregister_center
        AND cr.id = inv.cashregister_id
        JOIN
            puregym_switzerland.invoice_lines_mt invl
        ON
            invl.center = inv.center
        AND invl.id = inv.id
        JOIN
            products pr
        ON
            pr.center = invl.productcenter
        AND pr.id = invl.productid
        JOIN
            puregym_switzerland.product_and_product_group_link prgl
        ON
            prgl.product_center = pr.center
        AND prgl.product_id = pr.id
        AND prgl.product_group_id = 1001
        JOIN
            persons p
        ON
            p.center = invl.person_center
        AND p.id = invl.person_id
        WHERE
            cr.type = 'VENDING'
        AND inv.trans_time BETWEEN par.fromDate AND par.toDate) t
LEFT JOIN
    (   SELECT
            s.owner_center,
            s.owner_id,
            s.start_date,
            s.end_date,
            prod.name,
            s.center,
            s.id
        FROM
            subscriptions s
        JOIN
            subscriptiontypes st
        ON
            st.center = s.subscriptiontype_center
        AND st.id = s.subscriptiontype_id
        JOIN
            products prod
        ON
            prod.center = st.center
        AND prod.id = st.id) sub
ON
    sub.owner_center = t.center
AND sub.owner_id = t.id
AND sub.start_date <= t.cutdate
AND
    (
        sub.end_date >= t.cutdate
    OR  sub.end_date IS NULL)
LEFT JOIN
    (   SELECT
            sa.subscription_center,
            sa.subscription_id,
            sa.start_date,
            sa.end_date,
            mpr.cached_productname AS addon_name
        FROM
            puregym_switzerland.subscription_addon sa
        JOIN
            masterproductregister mpr
        ON
            sa.addon_product_id = mpr.id
        WHERE
            mpr.globalid IN ('ALL_IN_ONE_6',
                             'NUTRITION_6',
                             'NUTRITION_3',
                             'NUTRITION_12',
                             'ALL_IN_ONE_12',
                             'ALL_IN_ONE_3',
                             'LIVE_GROUP_FITNESS_24_1',
                             'ALL_IN_ONE_24',
                             'ALL_IN_ONE_1',
                             'NUTRITION_1') ) sub_add
ON
    sub_add.subscription_center = sub.center
AND sub_add.subscription_id = sub.id
AND sub_add.start_date <= t.cutdate
AND
    (
        sub_add.end_date >= t.cutdate
    OR  sub_add.end_date IS NULL)