SELECT
    recount.*,
    CASE
        WHEN TRUNC(recount.LastRecountedDate) >= $$DateFrom$$
            AND TRUNC(recount.LastRecountedDate) <= $$DateTo$$
        THEN 'YES'
        ELSE 'NO'
    END AS LASTRECOUNTED,
	$$DateFrom$$ AS DateFrom,
	$$DateTo$$ AS DateTo
FROM
    (
        SELECT
            c.id                                             AS CenterID,
            c.shortname                                      AS CenterName,
            it.balance_quantity                              AS "Not recounted quantity",
            it.balance_value                                 AS "Not recounted value (cost)",
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
            product_group pg
        ON
            pg.id = prod.primary_product_group_id
        JOIN
            centers c
        ON
            c.id = prod.center
        WHERE
            prod.ptype = 1
            AND prod.blocked = 0
            AND it.balance_quantity != 0
            AND prod.center IN ($$Scope$$) )recount