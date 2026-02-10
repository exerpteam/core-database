-- The extract is extracted from Exerp on 2026-02-08
-- https://clublead.atlassian.net/browse/EC-10287
SELECT
    pr.globalid AS "Package Code"
    , pr.name   AS "Package Description"
    , c.name    AS "Site Name"
    , pg.name   AS "Package Group"
    , COALESCE(SUM((s.state in(2,4))::INTEGER),0) AS "Member Count"
    , CASE
        WHEN st.PERIODUNIT = 0
        THEN 'WEEK'
        WHEN st.PERIODUNIT = 1
        THEN 'DAY'
        WHEN st.PERIODUNIT = 2
        THEN 'MONTH'
        WHEN st.PERIODUNIT = 3
        THEN 'YEAR'
    END              AS "Period Unit"
    , st.PERIODCOUNT AS "Period Count"
    , lic.start_Date <=CURRENT_DATE
AND
    (
        lic.stop_Date > CURRENT_DATE
    OR  lic.stop_date IS NULL)
                                             AS "Site Active"
    ,c.external_id                           AS "Site Code "
    ,jfpr.price                              AS "Joining Fee"
    ,COALESCE(s.subscription_price,pr.price) AS "Membership Fee"
    ,frpr.price                              AS "Freeze Fee"
FROM
    products pr
LEFT JOIN
    subscriptions s
ON
    s.subscriptiontype_center = pr.center
AND s.subscriptiontype_id = pr.id
JOIN
    product_group pg
ON
    pg.id = pr.primary_product_group_id
JOIN
    subscriptiontypes st
ON
    st.center = pr.center
AND st.id = pr.id
LEFT JOIN
    licenses lic
ON
    lic.center_id = pr.center
AND lic.feature = 'clubLead'
JOIN
    centers c
ON
    c.id = pr.center
JOIN
    products jfpr
ON
    jfpr.center = st.productnew_center
AND jfpr.id = st.productnew_id
LEFT JOIN
    products frpr
ON
    frpr.center = st.freezeperiodproduct_center
AND frpr.id = st.freezeperiodproduct_id
where c.id in ($$scope$$)
GROUP BY
    pr.globalid
    , pr.name
    , c.name
    , pg.name
    , st.periodunit
    , st.periodcount
    , lic.start_Date
    , lic.stop_date
    , c.external_id
    , jfpr.price
    ,COALESCE(s.subscription_price,pr.price)
    ,frpr.price