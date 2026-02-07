SELECT DISTINCT
    pr.name AS product_name,
    pr.price,
    r.rolename AS required_role,
    pr.needs_privilege,
    pr.show_in_sale,
    pr.returnable,
    pr.show_on_web,
    pr.show_on_mobile_api,
    pg_primary.name                   AS primary_product_group,
    STRING_AGG(DISTINCT pg.name, ';') AS product_groups,
    pac.name                          AS product_account_config,
	pr.GLOBALID
FROM
    products pr
JOIN
    product_and_product_group_link ppgl
ON
    ppgl.product_center = pr.center
AND ppgl.product_id = pr.id
JOIN
    product_group pg
ON
    pg.id = ppgl.product_group_id
AND pg.state = 'ACTIVE'
JOIN
    product_account_configurations pac
ON
    pac.id = pr.product_account_config_id
JOIN
    product_group pg_primary
ON
    pg_primary.id = pr.primary_product_group_id
JOIN
    masterproductregister mpr
ON
    mpr.globalid = pr.globalid
LEFT JOIN
    roles r
ON
    r.id = pr.requiredrole
WHERE
    pr.ptype = 1
AND mpr.state NOT IN ('DELETED',
                      'INACTIVE')
GROUP BY
    pr.name,
    pr.price,
    r.rolename,
    pr.needs_privilege,
    pr.show_in_sale,
    pr.returnable,
    pr.show_on_web,
    pr.show_on_mobile_api,
    pg_primary.name,
    pac.name,
	pr.GLOBALID
