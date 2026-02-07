SELECT
    pp.name AS SanctionProduct,
    mpr.cached_productname AS ProductName,
    mpr.globalid AS GlobalID,
    CASE
        WHEN pg.granter_service = 'GlobalCard' THEN 'Clipcard'
        WHEN pg.granter_service = 'Addon' THEN 'Add-On'
        WHEN pg.granter_service = 'GlobalSubscription' THEN 'Subscription'
        WHEN pg.granter_service = 'ReceiverGroup' THEN 'Target Group'
            ELSE 'undefined'
        END AS "ProductType"
FROM
    privilege_grants pg
JOIN
    masterproductregister mpr
ON
    pg.granter_id=mpr.id
LEFT JOIN
    privilege_punishments pp
ON
    pg.punishment=pp.id
WHERE
pg.valid_to IS NULL
AND pp.id is not NULL;