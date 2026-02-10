-- The extract is extracted from Exerp on 2026-02-08
--  
WITH barcode_list AS MATERIALIZED
(
        SELECT
                r1.*
        FROM
        (
                SELECT 
                        rank() over(partition by s1.ref_globalid ORDER BY s1.last_modified, s1.id DESC) as rnk,
                        s1.identity,
                        s1.start_time,
                        s1.ref_globalid,
                        s1.scope_type,
                        s1.scope_id
                FROM
                (
                        SELECT
                                (CASE 
                                        WHEN ei.scope_id IS NULL THEN 0
                                        ELSE ei.scope_id
                                END) AS scope_id,
                                (CASE 
                                        WHEN ei.scope_type IS NULL THEN 'NO SCOPE'
                                        ELSE ei.scope_type
                                END) AS scope_type,
                                ei.identity,
                                ei.id,
                                ei.last_modified,
                                ei.start_time,
                                ei.ref_globalid
                        FROM
                                sats.entityidentifiers ei
                        WHERE
                                ei.idmethod = 1 
                                AND ei.ref_type = 4
                                AND ei.quantity = 1
                                AND ei.entitystatus = 1
                                AND EXISTS
                                (
                                        SELECT
                                                1
                                        FROM sats.masterproductregister mpr
                                        WHERE
                                                mpr.globalid = ei.ref_globalid
                                                AND mpr.state IN ('INACTIVE')
                                )
                        
                ) s1
                        
        ) r1
        WHERE
                r1.rnk = 1
)
SELECT 
        
        t1.product_center,
        'D' as delievery,
        '01122022113050' as date,
        pr.name,
        bl.identity AS Barcode,
        t1.balance_quantity*-1
        
FROM
(
        SELECT
                rank() over(partition by i.id, it.product_center, it.product_id ORDER BY it.entry_time DESC) as rnk,
                i.id,
                i.state,
                it.type,
                it.coment, 
                it.product_center,
                it.product_id,
                longtodatec(it.entry_time, it.product_center) as entry_time,
                it.balance_quantity,
                it.balance_value,
                it.quantity,
                it.employee_center,
                it.employee_id
                
        FROM sats.inventory i
        JOIN sats.centers c ON i.center = c.id AND c.country = 'SE'
        JOIN sats.inventory_trans it ON it.inventory = i.id
        WHERE 
                i.state = 'OPEN'
               and i.center in (:center)
                
) t1
JOIN sats.products pr ON t1.product_center = pr.center AND t1.product_id = pr.id
JOIN barcode_list bl ON bl.ref_globalid = pr.globalid
LEFT JOIN sats.areas a ON a.id = bl.scope_id AND bl.scope_type = 'A'
WHERE 
        t1.rnk = 1
      --  AND pr.blocked = false
        AND t1.balance_quantity < 0
       /* AND 
        (
                bl.scope_type = 'NO SCOPE'
                OR
                bl.scope_type = 'A' AND bl.scope_id = 285
                OR      
                bl.scope_type = 'A' AND bl.scope_id = 471
        )*/