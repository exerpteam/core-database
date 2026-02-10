-- The extract is extracted from Exerp on 2026-02-08
-- https://clublead.atlassian.net/browse/ST-3079
https://clublead.atlassian.net/browse/ST-3308
WITH
        params as
        (
                SELECT
                    /*+ materialize */
                    datetolongTZ(TO_CHAR(add_months(SYSDATE, -3), 'YYYY-MM-dd HH24:MI'), 'Europe/London') as cutDate
                FROM 
                    dual
        ) 
SELECT DISTINCT
    p.firstname,
    p.lastname,
    NULL,
    pin.identity AS PIN
FROM
    persons p
CROSS JOIN params
JOIN
    subscriptions s
ON
    s.owner_center = p.center
    AND s.owner_id = p.id
    AND s.state IN (2,4,8)
JOIN
    subscriptiontypes st
ON
    st.center = s.subscriptiontype_center
    AND st.id = s.subscriptiontype_id
JOIN
    products prod
ON
    prod.center = st.center
    AND prod.id = st.id
JOIN
    PRODUCT_AND_PRODUCT_GROUP_LINK pgl
ON
    pgl.product_center = prod.center
    AND pgl.product_id = prod.id
JOIN
    product_group pg
ON
    pg.id = pgl.product_group_id
LEFT JOIN
    SUBSCRIPTION_ADDON sa
ON
    sa.SUBSCRIPTION_CENTER = s.CENTER
    AND sa.SUBSCRIPTION_ID=s.ID
    AND NVL(sa.end_date, SYSDATE) > SYSDATE -1	
    AND sa.cancelled = 0
LEFT JOIN
    MASTERPRODUCTREGISTER m
ON
    sa.ADDON_PRODUCT_ID=m.ID
    AND m.cached_productname = 'Hydro Sports Massage'
    AND m.state = 'ACTIVE'
LEFT JOIN
    entityidentifiers pin
ON
    pin.ref_center = p.center
    AND pin.ref_id = p.id
    AND pin.idmethod = 5
WHERE
    (pg.name IN ('Extra Subscription', 'Extra Subscriptions MS') OR sa.id is not null)
    AND (
        p.center IN ($$Scope$$)
        OR EXISTS
        (
            SELECT
                1
            FROM
                checkins c
            WHERE
                c.person_center = p.center
                AND c.person_id = p.id
                AND c.checkin_center IN ($$Scope$$)
                AND c.checkin_time >= params.cutDate)) 