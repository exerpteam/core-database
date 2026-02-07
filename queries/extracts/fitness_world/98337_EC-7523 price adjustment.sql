-- This is the version from 2026-02-05
--  
WITH
    params AS materialized
    (
        SELECT
            CAST(datetolongC(TO_CHAR(TO_DATE('2023-01-01', 'YYYY-MM-DD'), 'YYYY-MM-DD'), c.id) AS
            BIGINT)                                    AS longdate,
            TO_DATE(getcentertime(c.id), 'YYYY-MM-DD') AS today,
            c.id                                       AS centerid,
            c.name                                     AS centername
        FROM
            centers c
    )
SELECT
    params.centername      AS home_center,
    p.external_id,
    p.center ||'p'|| p.id  AS person_id,
    s.center ||'ss'|| s.id AS sub_id,
    prod.name              AS sub_name,
	sp.price               AS current_price
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
AND s.state IN (2)
AND s.start_date <= params.today - interval '6 months'
AND s.end_date IS NULL
JOIN
    subscription_price sp
ON
    sp.subscription_center = s.center
AND sp.subscription_id = s.id
AND sp.cancelled = 'false'
AND sp.to_date IS NULL
AND sp.from_date <= params.today
AND sp.price >= 50
JOIN
    subscriptiontypes st
ON
    st.center = s.subscriptiontype_center
AND st.id = s.subscriptiontype_id
AND st.st_type = 1
JOIN
    products prod
ON
    prod.center = st.center
AND prod.id = st.id
WHERE
    p.persontype = 0
AND p.status IN (1)
AND sp.price = prod.price
AND p.center IN (:scope)
AND p.sex != 'C'
    --NO OTHER PAYER
AND NOT EXISTS
    (
        SELECT
            1
        FROM
            persons per
        JOIN
            relatives r
        ON
            r.relativecenter = per.center
        AND r.relativeid = per.id
        AND r.status = 1
        AND per.persontype = 0
        AND per.status IN (1)
        AND per.center = p.center
        AND per.id = p.id )
    --NO OVERDUE DEBT
AND NOT EXISTS
    (
        SELECT
            1
        FROM
            persons per2
        JOIN
            account_receivables ar
        ON
            ar.customercenter = per2.center
        AND ar.customerid = per2.id
        AND ar.balance < 0
        JOIN
            ar_trans art
        ON
            art.center = ar.center
        AND art.id = ar.id
        AND art.due_date < params.today
        AND art.status IN ('NEW',
                           'OPEN')
        AND art.unsettled_amount < 0
        WHERE
            per2.persontype = 0
        AND per2.status IN (1)
        AND per2.center = p.center
        AND per2.id = p.id)
    -- NO TRANSFERS FROM 286 AND 267 AND 208, 210, 142, IN 2023
AND NOT EXISTS
    (
        SELECT
            1
        FROM
            persons per3
        JOIN
            state_change_log scl
        ON
            scl.center = per3.center
        AND scl.id = per3.id
        AND scl.entry_type = 1
        AND scl.stateid = 4
        AND scl.center IN (286, 208, 210, 142,
                           267)
        AND scl.entry_start_time > params.longdate
        JOIN
            persons curr_per3
        ON
            curr_per3.center = per3.current_person_center
        AND curr_per3.id = per3.current_person_id
        WHERE
            curr_per3.persontype = 0
        AND curr_per3.status IN (1)
        AND curr_per3.center = p.center
        AND curr_per3.id = p.id )
    --NO FUTURE SUBSCRIPTIONS
AND NOT EXISTS
    (
        SELECT
            1
        FROM
            persons per4
        JOIN
            subscriptions s4
        ON
            s4.owner_center = per4.center
        AND s4.owner_id = per4.id
        AND s4.start_date > params.today
        WHERE
            per4.persontype = 0
        AND per4.status IN (1)
        AND per4.center = p.center
        AND per4.id = p.id )
ORDER BY
p.center,
p.id