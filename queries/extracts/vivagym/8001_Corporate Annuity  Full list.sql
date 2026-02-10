-- The extract is extracted from Exerp on 2026-02-08
--  
SELECT
        p.center || 'p' || p.id AS PersonId,
        p.external_id,
        pea.txtvalue AS CORPANNUALFEE,
        (CASE
                WHEN p.persontype = 4 THEN 'YES'
                ELSE 'NO'
        END) AS is_corporate,
        (CASE
                WHEN p.status IN (1,3) THEN 'YES'
                ELSE 'NO'
        END) AS is_active,
        (CASE
                WHEN EXISTS 
                ( SELECT 
                        1
                  FROM vivagym.subscriptions s
                  JOIN vivagym.products pr ON pr.center = s.subscriptiontype_center AND pr.id = s.subscriptiontype_id
                  JOIN vivagym.product_and_product_group_link ppgl ON pr.center = ppgl.product_center AND pr.id = ppgl.product_id
                  JOIN vivagym.product_group pg ON pg.id = ppgl.product_group_id AND pg.name = 'Annuity Fee'
                  WHERE
                        s.owner_center = p.center AND s.owner_id = p.id
                        AND s.state IN (2,4,8)
                ) THEN 'YES'
                ELSE 'NO'
         END) AS has_valid_subscription,
         (CASE
                WHEN 
                        (
                                date_part('month', AGE(CAST(pea.txtvalue AS DATE) - interval '1 days')) = 0
                                AND date_part('day', AGE(CAST(pea.txtvalue AS DATE) - interval '1 days')) = 0
                                AND date_part('year', AGE(CAST(pea.txtvalue AS DATE) - interval '1 days')) >= 1
                        )
                THEN 'YES'
                ELSE 'NO'
         END) AS is_anniversary_tomorrow
FROM
        vivagym.persons p
JOIN vivagym.person_ext_attrs pea 
        ON p.center = pea.personcenter AND p.id = pea.personid AND pea.name = 'CORPANNUALFEE'
WHERE
        pea.txtvalue IS NOT NULL