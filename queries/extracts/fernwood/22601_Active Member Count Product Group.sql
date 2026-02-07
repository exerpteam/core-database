SELECT
        prod.name AS Product_Name
        ,prod.globalid AS Product_Global_id
        ,c.shortname AS Center
        ,prod.blocked
FROM
        fernwood.products prod
JOIN
        (
                SELECT
                        *
                FROM
                        (                        
                                SELECT
                                        prod.globalid
                                        ,count(prod.globalid) counting
                                FROM
                                        products prod
                                JOIN
                                        product_and_product_group_link pgl
                                        ON pgl.product_center = prod.center
                                        AND pgl.product_id = prod.id
                                        AND pgl.product_group_id = 5601
                                WHERE
                                        prod.ptype IN (4,10,13)
                                GROUP BY
                                        prod.globalid
                        )t
                WHERE 
                        t.counting < 81
        )t
        ON t.globalid = prod.globalid
LEFT JOIN
        product_and_product_group_link pgl
        ON pgl.product_center = prod.center
        AND pgl.product_id = prod.id
        AND pgl.product_group_id = 5601
JOIN
        fernwood.centers c
        ON c.id = prod.center          
WHERE
        pgl.product_group_id IS NULL             
                                                                                                        
