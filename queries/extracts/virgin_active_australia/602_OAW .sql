-- This is the version from 2026-02-05
--  
SELECT
        t1.center,
        t1.id,
        t1.center || 'p' || t1.id AS "PERSONKEY"  
FROM        
(       
        WITH PARAMS AS MATERIALIZED
        (
                SELECT
                        extract(DOW FROM TO_DATE(GETCENTERTIME(c.id), 'YYYY-MM-DD HH24:MI')) AS edate,
                        c.id AS  center_id
                FROM centers c
                WHERE c.country = 'AU'
        )
        SELECT 
                DISTINCT
                p.center,
                p.id
        FROM persons p
        JOIN params
                ON params.center_id = p.center
        JOIN subscriptions s
                ON s.owner_center = p.center
                AND s.owner_id = p.id 
        JOIN products pr
                ON s.subscriptiontype_center = pr.center 
                AND s.subscriptiontype_id = pr.id
        JOIN product_and_product_group_link pgl
                ON pr.center = pgl.product_center
                AND pr.id = pgl.product_id
        WHERE
                p.status IN (1,3)
                AND p.center IN (:center)                
                AND s.state = 2 
                AND s.sub_state != 9
                AND pgl.product_group_id = 803 -- Product group OAW
                AND params.edate = 1            -- Monday
) t1