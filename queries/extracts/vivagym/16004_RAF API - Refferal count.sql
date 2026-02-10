-- The extract is extracted from Exerp on 2026-02-08
--  
WITH
    params AS materialized
    (
        SELECT
            id,
            datetolongc(TO_CHAR(date_trunc('month', CURRENT_DATE), 'YYYY-MM-DD'),id) AS fromtime,
            datetolongc(TO_CHAR(date_trunc('month', CURRENT_DATE) + interval '1 month',
            'YYYY-MM-DD'),id) AS totime
        FROM
            centers
    )
SELECT
    cast(referral_count_used<referral_count
AND referral_count IS NOT NULL as text) AS referral_allowed,
    coalesce(referral_count,0) as referral_count,
    coalesce(referral_count_used,0) as referral_count_used
FROM
    persons p
LEFT JOIN
    (
        SELECT
            p.center,
            p.id,
            COUNT(je.*) AS referral_count_used,
            3           AS referral_count
        FROM
            persons p
        JOIN
            params
        ON
            params.id = p.center
        left JOIN
            journalentries je
        ON
            je.person_center = p.center
        AND je.person_id = p.id
        AND je.jetype = 3
        AND je.name = 'refer a friend - member'
        AND je.creation_time BETWEEN params.fromtime AND params.totime
        WHERE
            p.transfers_current_prs_center = $$center$$
        AND p.transfers_current_prs_id = $$id$$
        AND EXISTS -- member has active subscription that is not 'Price For Life'
            (
                SELECT
                    1
                FROM
                    subscriptions s
                WHERE
                    s.owner_center = p.center
                AND s.owner_id = p.id
                AND s.state IN (2,4)
                AND NOT EXISTS
                    (
                        SELECT
                            1
                        FROM
                            product_and_product_group_link ppgl
                        JOIN
                            product_group pg
                        ON
                            pg.id = ppgl.product_group_id
                        AND pg.name IN('Price for Life',
                                       'Staff Memberships',
                                       'Marketing Subscriptions',
                                       'Neutras',
                                       'Daypass')
                        WHERE
                            ppgl.product_center = s.subscriptiontype_center
                        AND ppgl.product_id = s.subscriptiontype_id ))
        GROUP BY
            p.center,
            p.id) usage
ON
    usage.center = p.center
AND usage.id = p.id
WHERE
    p.center = $$center$$
AND p.id = $$id$$