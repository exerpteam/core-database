WITH
    params AS materialized
    (
        SELECT
            CAST(datetolong(TO_CHAR(TO_DATE((:fromdate), 'YYYY-MM-DD'), 'YYYY-MM-DD')) AS BIGINT)
                                                                                        AS fromdate,
            CAST(datetolong(TO_CHAR(TO_DATE((:todate), 'YYYY-MM-DD'), 'YYYY-MM-DD')) AS BIGINT)+86400000-1 AS
                    todate,
            c.id AS centerid
        FROM
            centers c
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
s.creator_center = 100
AND s.creator_id = 4206
AND s.creation_time BETWEEN params.fromdate AND params.todate
ORDER BY
c.id,
s.creation_time