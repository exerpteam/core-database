-- The extract is extracted from Exerp on 2026-02-08
--  
WITH
    params AS materialized
    (
        SELECT
            --TO_DATE(getcentertime(c.id), 'YYYY-MM-DD')                     AS currentDate,
            TO_DATE(getcentertime(c.id), 'YYYY-MM-DD') - interval '1 day' AS cutDate,
            c.id                                                           AS centerid
        FROM
            centers c
        WHERE
            c.country = 'GB'
    )
SELECT
    p.center,
    p.id,
    p.center ||'p'|| p.id AS "PERSONKEY",
    p.external_id,
    t1.name       AS product_group,
    lcid.txtvalue AS lcid,
    laid.txtvalue AS laid,
    loy.txtvalue  AS loyalty,
    s.binding_end_date AS binding_end_date
FROM
    subscription_change sc
JOIN
    subscriptions s
ON
    s.center = sc.new_subscription_center
AND s.id = sc.new_subscription_id
JOIN
    params par
ON
    par.centerid = s.center
JOIN
    persons p
ON
    p.center = s.owner_center
AND p.id = s.owner_id
JOIN
    person_ext_attrs lcid
ON
    lcid.personcenter = p.center
AND lcid.personid = p.id
AND lcid.name = 'LCID'
JOIN
    person_ext_attrs laid
ON
    laid.personcenter = p.center
AND laid.personid = p.id
AND laid.name = 'LAID'
JOIN
    person_ext_attrs loy
ON
    loy.personcenter = p.center
AND loy.personid = p.id
AND loy.name = 'LOYALTY'
LEFT JOIN
(SELECT
sub.center,
sub.id,
pg.name
FROM
subscriptions sub
JOIN
    subscriptiontypes st
ON
    st.center = sub.subscriptiontype_center
AND st.id = sub.subscriptiontype_id
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
pg.name LIKE '%capi-loyalty%'
--pg.id IN (47201,47202,47001,47002) 
) t1
ON
t1.center = s.center
AND t1.id = s.id 
WHERE
    sc.type NOT IN ('END_DATE',
                    'TRANSFER',
                    'SALES_EMPLOYEE')
AND sc.cancel_time IS NULL
AND s.start_date = par.cutDate
--AND s.start_date <= par.currentDate
AND s.state IN (2,4)
AND p.center IN (:center)