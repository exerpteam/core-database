-- The extract is extracted from Exerp on 2026-02-08
--  
WITH
    params AS MATERIALIZED
    (   SELECT
            CAST(datetolongC(TO_CHAR(TO_DATE((:fromDate), 'YYYY-MM-DD'), 'YYYY-MM-DD'), c.id) AS BIGINT) AS cutDate,
            c.id                                        AS centerId
        FROM
            centers c
        WHERE
            c.country = 'DK'
    )
SELECT
    DISTINCT t.center ||'p'|| t.id AS person_key,
    t.sub_center ||'p'|| t.sub_id  AS sub_key,
    t.subscription_price           AS current_price,
    t.globalid                     AS new_sub_globalid,
    t.name                         AS new_sub_name,
    t2.old_sub_globalid,
    t2.old_sub_name,
    t.change_date
FROM
    (   SELECT
            s.center AS sub_center,
            s.id     AS sub_id,
            p.center,
            p.id,
            pr.globalid,
            pr.name,
            s.subscription_price,
            pr.price                                                       AS new_price,
            TO_CHAR(longtodateC(je.creation_time, p.center), 'YYYY-MM-DD') AS change_date
        FROM
            persons p
        JOIN
            params par
        ON
            par.centerId = p.center
        JOIN
            journalentries je
        ON
            je.person_center = p.center
        AND je.person_id = p.id
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
        JOIN
            subscription_price sp
        ON
            sp.subscription_center = s.center
        AND sp.subscription_id = s.id
        WHERE
            je.name = 'Apply step: Change subscription type in database'
        AND je.creatorcenter = 100
        AND je.creatorid IN (40098,
                             94298)
        AND s.state IN (2,4)
        AND je.creation_time >= cutDate
        AND pr.globalid NOT LIKE '%U30'
        AND p.center IN (:scope) ) t
JOIN
    (   SELECT
            TO_CHAR(longtodateC(MAX(inv.trans_time), inv.center), 'YYYY-MM-DD') AS inv_date,
            invl.person_center,
            invl.person_id,
            prod.name     AS old_sub_name,
            prod.globalid AS old_sub_globalid
        FROM
            invoices inv
        JOIN
            sats.invoice_lines_mt invl
        ON
            invl.center = inv.center
        AND invl.id = inv.id
        JOIN
            products prod
        ON
            prod.center = invl.productcenter
        AND prod.id = invl.productid
        AND prod.ptype = 10
        WHERE
            prod.globalid IN ('1CLUB_ALLDAY_BND_GX_U30',
                              'REGION_ALLDAY_BND_GX_U30',
                              'PREMIUM_BND_U30',
                              '1CLUB_ALLDAY_NOBND_GX_U30',
                              'REGION_ALLDAY_NOBND_GX_U30',
                              'PREMIUM_NOBND_U30')
        GROUP BY
            inv.center,
            invl.person_center,
            invl.person_id,
            prod.name,
            prod.globalid) t2
ON
    t2.person_center = t.center
AND t2.person_id = t.id
AND t2.inv_date < t.change_date