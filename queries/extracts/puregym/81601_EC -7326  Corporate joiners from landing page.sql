-- The extract is extracted from Exerp on 2026-02-08
--  
WITH
    params AS materialized
    (
        SELECT
            CAST(datetolong(TO_CHAR(TO_DATE((:fromdate), 'YYYY-MM-DD'), 'YYYY-MM-DD')) AS BIGINT)
            AS fromdate,
            CAST(datetolong(TO_CHAR(TO_DATE((:todate), 'YYYY-MM-DD'), 'YYYY-MM-DD')) AS BIGINT)
            +90000000 -1 AS todate,
            c.id         AS centerid
        FROM
            centers c
    )
    ,
    corp_state_change AS
    (
        SELECT
            scl.center,
            scl.id
        FROM
            puregym.state_change_log scl
        JOIN
            params
        ON
            params.centerid = scl.center
        WHERE
            scl.entry_type = 3
        AND scl.employee_center = 100
        AND scl.employee_id IN (17401,
                                99801)
        AND scl.stateid = 4
        AND scl.entry_start_time BETWEEN params.fromdate AND params.todate
    )
    ,
    sub_change AS
    (
        SELECT
            *
        FROM
            puregym.subscription_change sc
        JOIN
            params
        ON
            sc.new_subscription_center = params.centerid
        WHERE
            sc.type IN ('TRANSFER',
                        'TYPE',
                        'EXTENSION')
        AND sc.change_time BETWEEN params.fromdate AND params.todate
        AND sc.employee_center = 100
        AND sc.employee_id IN (17401,
                               99801)
    )
SELECT
    c.name                                     AS center,
    comp.fullname                              AS company_name,
    comp.center ||'p'|| comp.id                AS company_id,
    ca.center ||'p'|| ca.id ||'rpt'|| ca.subid AS agreement_id,
    pr.name                                    AS subscription,
    p.external_id                              AS external_id,
    p.center ||'p'|| p.id                      AS member_id,
    longtodate(s.creation_time)                AS sales_date,
    s.center ||'ss'|| s.id                     AS Subscription_id
FROM
    persons p
JOIN
    centers c
ON
    c.id = p.center
LEFT JOIN
    corp_state_change csc
ON
    csc.center = p.center
AND csc.id = p.id
JOIN
    relatives r
ON
    r.center = p.center
AND r.id = p.id
AND r.rtype = 3
AND r.status = 1
JOIN
    companyagreements ca
ON
    ca.center = r.relativecenter
AND ca.id = r.relativeid
AND ca.subid = r.relativesubid
JOIN
    persons comp
ON
    comp.center = ca.center
AND comp.id = ca.id
JOIN
    subscriptions s
ON
    s.owner_center = p.center
AND s.owner_id = p.id
AND s.state IN (2,4,8)
LEFT JOIN
    sub_change sc
ON
    sc.new_subscription_center = s.center
AND sc.new_subscription_id = s.id
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
    params
ON
    params.centerid = s.center
WHERE
    s.creation_time BETWEEN params.fromdate AND params.todate
AND s.creator_center = 100
AND s.creator_id IN (17401,
                     99801)
AND sc.old_subscription_center IS NULL
AND NOT EXISTS
    (
        SELECT
            1
        FROM
            subscription_change sc2
        WHERE
            sc2.type IN ('TRANSFER',
                         'TYPE',
                         'EXTENSION')
        AND sc2.new_subscription_center = s.center
        AND sc2.new_subscription_id = s.id )
ORDER BY
    c.id,
    s.creation_time