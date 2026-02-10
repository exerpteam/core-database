-- The extract is extracted from Exerp on 2026-02-08
--  
SELECT
    p.external_id
    ,GREATEST(CAST(trim(trim(trim(trim(fb_dis.txtvalue,'Legacy'),'LEGACY') ,'%'),' ') AS INTEGER), 
    CAST (MAX(pp.price_modification_amount)*100 AS                                       INTEGER) 
    ) AS FBDISCOUNT
FROM
    persons p
LEFT JOIN
    subscriptions s
ON
    p.center = s.owner_center
AND p.id = s.owner_id
LEFT JOIN
    products pr
ON
    pr.center = s.subscriptiontype_center
AND pr.id = s.subscriptiontype_id
LEFT JOIN
    masterproductregister mpr
ON
    mpr.globalid = pr.globalid
LEFT JOIN
    privilege_grants pg
ON
    pg.granter_service = 'GlobalSubscription'
AND mpr.id = pg.granter_id
LEFT JOIN
    privilege_sets ps
ON
    pg.privilege_set = ps.id
    --AND ps.privilege_set_groups_id = 411 -- F&B Discount
LEFT JOIN
    PRODUCT_PRIVILEGES pp
ON
    pp.PRIVILEGE_SET = ps.id
AND pp.ref_type = 'PRODUCT_GROUP'
AND pp.ref_id = 404
AND pp.valid_to IS NULL
LEFT JOIN
    person_ext_attrs fb_dis
ON
    fb_dis.personcenter = p.center
AND fb_dis.personid = p.id
AND fb_dis.name = 'FBDISCOUNT'
GROUP BY
    p.external_id
    ,fb_dis.txtvalue