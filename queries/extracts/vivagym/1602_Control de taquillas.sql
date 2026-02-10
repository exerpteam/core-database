-- The extract is extracted from Exerp on 2026-02-08
--  
WITH with_taquilla AS
(
        WITH params AS
        (
                SELECT
                        TO_DATE(getcentertime(c.id), 'YYYY-MM-DD') AS today,
                        c.id AS center_id,
                        c.name
                FROM
                        vivagym.centers c
        )
        SELECT
                par.name AS center_name,
                p.external_id,
                p.center,
                p.id,
                mpr.cached_productname AS product_name,
                mpr.globalid AS global_id,
                sa.start_date AS addon_start_date,
                sa.end_date AS addon_end_date
        FROM vivagym.persons p
        JOIN vivagym.subscriptions s ON p.center = s.owner_center AND p.id= s.owner_id
        JOIN vivagym.subscription_addon sa ON sa.subscription_center = s.center AND sa.subscription_id = s.id
        JOIN vivagym.masterproductregister mpr ON sa.addon_product_id = mpr.id
        JOIN params par ON par.center_id = sa.center_id
        WHERE
                sa.cancelled = false
                AND sa.start_date <= par.today
                AND (sa.end_date >= par.today OR sa.end_date IS NULL)
                AND mpr.globalid = 'TAQUILLA'
)
SELECT
        wt.center_name,
        wt.external_id,
        wt.center || 'p' || wt.id AS person_id,
        wt.product_name,
        wt.global_id,
        wt.addon_start_date,
        wt.addon_end_date,
        pea.txtvalue AS taquilla_attr
FROM
        with_taquilla wt
LEFT JOIN
        vivagym.person_ext_attrs pea ON wt.center = pea.personcenter AND wt.id = pea.personid AND pea.name = 'NUMEROTAQUILLA'
WHERE
	wt.center IN (:Scope)
UNION ALL
SELECT
        c.name AS center_name,
        p.external_id,
        p.center || 'p' || p.id AS person_id,
        NULL,
        NULL,
        NULL,
        NULL,
        pea2.txtvalue AS taquilla_attr
FROM
        vivagym.persons p
JOIN 
        vivagym.person_ext_attrs pea2 ON p.center = pea2.personcenter AND p.id = pea2.personid AND pea2.name = 'NUMEROTAQUILLA'
JOIN
        vivagym.centers c ON p.center = c.id
WHERE
		p.center IN (:Scope) AND
pea2.txtvalue not like '' and
        (p.center, p.id) NOT IN 
        (
                SELECT
                        wt.center,
                        wt.id
                FROM
                        with_taquilla wt
        )
        