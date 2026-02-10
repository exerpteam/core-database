-- The extract is extracted from Exerp on 2026-02-08
--  
     SELECT
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
            WHERE
            ( mpr.cached_productname = 'VivaBox'
                AND sa.center_id IN (:center) )-- OR sa.id = 1421480