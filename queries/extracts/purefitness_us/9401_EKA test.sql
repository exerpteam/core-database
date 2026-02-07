SELECT
        t1.*
FROM
(
        WITH params AS MATERIALIZED
        (
                SELECT
                        extract(DAY FROM(TO_DATE(getCenterTime(c.id), 'YYYY-MM-DD'))) AS executionDate,
                        TO_DATE(getCenterTime(c.id), 'YYYY-MM-DD') AS todays_date,
                        datetolongc(TO_CHAR(TO_DATE(getCenterTime(c.id), 'YYYY-MM-DD') - interval '25 days', 'YYYY-MM-DD'),c.id) AS twentyfive_days_ago,
                        c.id AS centerId
                FROM
                        centers c
        )
        SELECT
                DISTINCT 
                p.center,
                p.id,
                p.center || 'p' || p.id AS "PERSONKEY"
        FROM persons p
        JOIN params par
                ON par.centerId = p.center
        JOIN subscriptions s
                ON s.owner_center = p.center AND s.owner_id = p.id
        JOIN products pr
                ON s.subscriptiontype_center = pr.center AND s.subscriptiontype_id = pr.id
        JOIN account_receivables ar
                ON ar.customercenter = p.center AND ar.customerid = p.id
        JOIN payment_accounts pac
                ON ar.center = pac.center AND ar.id = pac.id
        JOIN payment_agreements pag
                ON pag.center = pac.active_agr_center AND pag.id = pac.active_agr_id AND pag.subid = pac.active_agr_subid
        WHERE
                -- Applies to subscription state active and frozen
                s.state IN (2,4)
                -- Exclude blocked subscriptions
                AND s.sub_state NOT IN (9) 
                -- Person is active or temporary inactive
                AND p.status IN (1,3)
                AND pag.individual_deduction_day IS NOT NULL
                AND par.executionDate = pag.individual_deduction_day
                AND EXISTS
                (
                        SELECT 1
                        FROM product_and_product_group_link plink
                        WHERE
                                plink.product_center = pr.center
                                AND plink.product_id = pr.id
                                AND plink.product_group_id IN (1802) -- PREMIUM
                )
                -- Does not apply to members that are blacklisted, blocked or suspended
                AND p.blacklisted=0 
                AND p.center = :center
                AND s.start_date < par.todays_date
                AND NOT EXISTS
                (
                        SELECT
                        FROM clipcards cc
                        JOIN products prod ON cc.center = prod.center AND cc.id = prod.id
                        WHERE
                                cc.owner_center = p.center
                                AND cc.owner_id = p.id
                                AND prod.globalid = 'BAF_MEMBER_CLIPCARD' 
                                AND cc.valid_from > par.twentyfive_days_ago
                )
) t1