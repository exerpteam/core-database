-- The extract is extracted from Exerp on 2026-02-08
--  
WITH
    params AS MATERIALIZED
    (   SELECT
            DATE_TRUNC('month', (TO_DATE(getcentertime(c.id), 'YYYY-MM-DD'))) - interval
            '30 years' + interval '1 month' - interval '1 day' AS cutDate,
            DATE_TRUNC('month', TO_DATE(getcentertime(c.id), 'YYYY-MM-DD')) + interval '1 month'
            AS new_sub_startdate,
            TO_CHAR(DATE_TRUNC('month', TO_DATE(getcentertime(c.id), 'YYYY-MM-DD')) + interval
            '1 month' - interval '2 day', 'DD')                                    AS Adyen_cutDate,
            CAST(TO_CHAR(TO_DATE(getcentertime(c.id), 'YYYY-MM-DD'), 'DD') AS INT) AS exeDate,
            c.id                                                                   AS centerId
        FROM
            centers c
        WHERE
            c.country = 'DK'
    )
SELECT
    t.center,
    t.id,
    t.center ||'p'|| t.id AS "PERSONKEY",
    t.external_id,
    t.birthdate,
    t.subscription_center        AS old_sub_center,
    t.subscription_id            AS old_sub_id,
    t.subscription_center||'ss'|| t.subscription_id as "ss number",
    newpr.center                 AS new_sub_prod_center,
    newpr.id                     AS new_sub_prod_id,
    newpr.globalid               as new_sub_globalid, 
    t.subscription_price         AS new_sub_price,
    t.new_subscription_startdate AS new_sub_startdate,
    t.globalid                   AS old_globalid,
    t.change_cutdate,
    t.exeDate
FROM
    (   SELECT
            p.center      AS center,
            p.id          AS id,
            p.external_id AS external_id,
            s.center      AS subscription_center,
            s.id          AS subscription_id,
            s.subscription_price,
            p.birthdate,
            TO_CHAR(par.new_sub_startdate, 'YYYY-MM-DD') AS new_subscription_startdate,
            pr.globalid,
            TRIM(TRAILING '_UDEN_MOMS' FROM pr.globalid) AS new_sub_globalid,
            CAST(par.Adyen_cutDate AS INT)               AS change_cutdate,
            par.exeDate
        FROM
            persons p
        JOIN
            params par
        ON
            par.centerId = p.center
        JOIN
            subscriptions s
        ON
            s.owner_center = p.center
        AND s.owner_id = p.id
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
        WHERE
            p.birthdate <= par.cutdate
        AND p.persontype != 2
        AND s.state = 2
        AND st.st_type = 1
        AND p.status NOT IN (4,5,7,8)
        AND p.sex != 'C'
        AND
            (
                s.end_date IS NULL
            OR  s.end_date >= par.new_sub_startdate)
        AND pr.globalid LIKE '%_UDEN_MOMS' ) t
JOIN
    products newpr
ON
    newpr.globalid = t.new_sub_globalid
AND newpr.center = t.subscription_center
WHERE
    t.exeDate = t.change_cutdate
AND t.center IN (:center)