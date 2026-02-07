SELECT
    c.id                                             AS CenterID,
    c.shortname                                      AS CenterName,
    it.balance_quantity                              AS "Not recounted quantity",
    it.balance_value                                 AS "Not recounted value (cost)",
    longtodatec($$DateFrom$$, prod.center)           AS DateFrom,
    longtodatec($$DateTo$$, prod.center)             AS DateTo,
    longtodatec(prod.last_recount_date, prod.center) AS LastRecountedDate,
    prod.name                                        AS ProductName,
    pg.name                                          AS ProductGroupName
FROM
    products prod
JOIN
    (
        SELECT
            itl.product_center,
            itl.product_id,
            MAX(itl.entry_time) AS max_entry_time
        FROM
            inventory_trans itl
        GROUP BY
            itl.product_center,
            itl.product_id) latest_inv
ON
    latest_inv.product_center = prod.center
    AND latest_inv.product_id = prod.id
JOIN
    inventory_trans it
ON
    it.product_center = latest_inv.product_center
    AND it.product_id = latest_inv.product_id
    AND it.entry_time = latest_inv.max_entry_time
JOIN
    PRODUCT_AND_PRODUCT_GROUP_LINK pgl
ON
    pgl.product_center = prod.center
    AND pgl.product_id = prod.id
JOIN
    product_group pg
ON
    pg.id = pgl.product_group_id
JOIN
    centers c
ON
    c.id = prod.center
WHERE
    prod.ptype = 1
    AND prod.blocked = 0
    AND (prod.last_recount_date IS NULL
        OR (
            prod.last_recount_date NOT BETWEEN $$DateFrom$$ AND $$DateTo$$))
    AND prod.center IN ($$Scope$$)