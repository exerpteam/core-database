-- The extract is extracted from Exerp on 2026-02-08
--  
WITH
    params AS materialized
    (
        SELECT
            TO_DATE(getcentertime(c.id), 'YYYY-MM-DD') - interval '4 years' + interval '10 days' AS from_date4,
            TO_DATE(getcentertime(c.id), 'YYYY-MM-DD') - interval '14 years' + interval '10 days' AS from_date14,
            TO_DATE(getcentertime(c.id), 'YYYY-MM-DD') + interval
            '1 month - 14 years - 10 days' AS to_date14,
            TO_DATE(getcentertime(c.id), 'YYYY-MM-DD') - interval '16 years' + interval '10 days' AS from_date16,
            TO_DATE(getcentertime(c.id), 'YYYY-MM-DD') + interval
            '1 month - 16 years - 10 days' AS to_date16,
            TO_DATE(getcentertime(c.id), 'YYYY-MM-DD') - interval '23 years' + interval '10 days' AS from_date23,
            TO_DATE(getcentertime(c.id), 'YYYY-MM-DD') + interval
            '1 month - 23 years + 10 days' AS to_date23,
            DATE_TRUNC('month', TO_DATE(getcentertime(c.id), 'YYYY-MM-DD')) + interval
            '1 month - 1 day' AS sub_enddate,
            /*DATE_TRUNC('month', TO_DATE(getcentertime(c.id), 'YYYY-MM-DD')) + interval
            '1 month' AS sub_startdate,
            CAST(datetolong(TO_CHAR(TO_TIMESTAMP(getcentertime(c.id), 'YYYY-MM-DD HH24:MI') -
            interval '10 minute', 'YYYY-MM-DD HH24:MI')) AS BIGINT) AS fromtime, */
            c.id AS centerid
        FROM
            centers c
    )
SELECT
    p.center ||'p'|| p.id AS "PERSONKEY",
    p.external_id AS external_id,
    p.birthdate,
    p.birthdate - interval '10 days' + interval '14 years' AS expected_upgrade_date,
    pr.name AS Existing_subscription,
    npr.name AS New_subscription,
    TO_CHAR(DATE_TRUNC('month', p.birthdate) + interval '14 years' + interval '1 month', 'YYYY-MM-DD') AS expected_new_subscription_startdate
FROM
    persons p
JOIN
    params
ON
    params.centerid = p.center
JOIN
    subscriptions s
ON
    s.owner_center = p.center
AND s.owner_id = p.id
JOIN
    villageurban.subscriptiontypes st
ON
    st.center = s.subscriptiontype_center
AND st.id = s.subscriptiontype_id
JOIN
    products pr
ON
    pr.center = st.center
AND pr.id = st.id
JOIN
    products npr
ON
    npr.center = p.center
AND npr.globalid = '14_15YRS_MONTHLY_FLEXIBLE'
WHERE
    p.birthdate < params.from_date14
AND s.state IN (2,4)
AND pr.globalid IN ('JUNIOR_FLEXIBLE', 'WEEKEND_JUNIOR_MONTHLY')
AND NOT EXISTS
    (
        SELECT
            1
        FROM
            subscriptions sub
        JOIN
            params
        ON
            params.centerid = sub.center
        WHERE
            sub.owner_center = p.center
        AND sub.owner_id = p.id
        AND sub.start_date > params.sub_enddate
        AND sub.state = 8 )
UNION ALL
SELECT
    p.center ||'p'|| p.id AS "PERSONKEY",
    p.external_id AS external_id,
    p.birthdate,
    p.birthdate - interval '10 days' + interval '16 years' AS expected_upgrade_date,
    pr.name AS Existing_subscription,
    npr.name AS New_subscription,
    TO_CHAR(DATE_TRUNC('month', p.birthdate) + interval '16 years' + interval '1 month', 'YYYY-MM-DD') AS expected_new_subscription_startdate
FROM
    persons p
JOIN
    params
ON
    params.centerid = p.center
JOIN
    subscriptions s
ON
    s.owner_center = p.center
AND s.owner_id = p.id
JOIN
    villageurban.subscriptiontypes st
ON
    st.center = s.subscriptiontype_center
AND st.id = s.subscriptiontype_id
JOIN
    products pr
ON
    pr.center = st.center
AND pr.id = st.id
JOIN
    products npr
ON
    npr.center = p.center
AND npr.globalid = 'YOUNG_PERSONS_MEMBERSHIP'
WHERE
    p.birthdate < params.from_date16
AND s.state IN (2,4)
AND pr.globalid IN ('14_15YRS_MONTHLY_FLEXIBLE')
AND NOT EXISTS
    (
        SELECT
            1
        FROM
            subscriptions sub
        JOIN
            params
        ON
            params.centerid = sub.center
        WHERE
            sub.owner_center = p.center
        AND sub.owner_id = p.id
        AND sub.start_date > params.sub_enddate
        AND sub.state = 8 )
UNION ALL
SELECT
    p.center ||'p'|| p.id AS "PERSONKEY",
    p.external_id AS external_id,
    p.birthdate,
    p.birthdate - interval '10 days' + interval '23 years' AS expected_upgrade_date,
    pr.name AS Existing_subscription,
    npr.name AS New_subscription,
    TO_CHAR(DATE_TRUNC('month', p.birthdate) + interval '23 years' + interval '1 month', 'YYYY-MM-DD') AS expected_new_subscription_startdate
FROM
    persons p
JOIN
    params
ON
    params.centerid = p.center
JOIN
    subscriptions s
ON
    s.owner_center = p.center
AND s.owner_id = p.id
JOIN
    villageurban.subscriptiontypes st
ON
    st.center = s.subscriptiontype_center
AND st.id = s.subscriptiontype_id
JOIN
    products pr
ON
    pr.center = st.center
AND pr.id = st.id
JOIN
    products npr
ON
    npr.center = p.center
AND npr.globalid = 'GOLD_MONTHLY_FLEXIBLE'
WHERE
    p.birthdate < params.from_date23
AND s.state IN (2,4)
AND pr.globalid IN ('YOUNG_PERSONS_MEMBERSHIP', 'YOUNG_PERSONS_RESULTS_MEMBERSH')
AND NOT EXISTS
    (
        SELECT
            1
        FROM
            subscriptions sub
        JOIN
            params
        ON
            params.centerid = sub.center
        WHERE
            sub.owner_center = p.center
        AND sub.owner_id = p.id
        AND sub.start_date > params.sub_enddate
        AND sub.state = 8 )
UNION ALL
SELECT
    p.center ||'p'|| p.id AS "PERSONKEY",
    p.external_id AS external_id,
    p.birthdate,
    p.birthdate - interval '10 days' + interval '4 years' AS expected_upgrade_date,
    pr.name AS Existing_subscription,
    npr.name AS New_subscription,
    TO_CHAR(DATE_TRUNC('month', p.birthdate) + interval '4 years' + interval '1 month', 'YYYY-MM-DD') AS expected_new_subscription_startdate
FROM
    persons p
JOIN
    params
ON
    params.centerid = p.center
JOIN
    subscriptions s
ON
    s.owner_center = p.center
AND s.owner_id = p.id
JOIN
    villageurban.subscriptiontypes st
ON
    st.center = s.subscriptiontype_center
AND st.id = s.subscriptiontype_id
JOIN
    products pr
ON
    pr.center = st.center
AND pr.id = st.id
JOIN
    products npr
ON
    npr.center = p.center
AND npr.globalid = 'JUNIOR_FLEXIBLE'
WHERE
    p.birthdate <= params.from_date4
AND s.state IN (2,4)
AND pr.globalid = 'JUNIOR_MONTHLY_FREE'
AND NOT EXISTS
    (
        SELECT
            1
        FROM
            subscriptions sub
        JOIN
            params
        ON
            params.centerid = sub.center
        WHERE
            sub.owner_center = p.center
        AND sub.owner_id = p.id
        AND sub.start_date > params.sub_enddate
        AND sub.state = 8 )