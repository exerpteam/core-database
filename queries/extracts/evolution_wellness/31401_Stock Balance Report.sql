SELECT DISTINCT ON (inv.product_center, inv.product_id)
    c.name AS "Center",
    i.name AS "Inventory",
    prod.name AS "Product Name",
    prod.external_id AS "External ID",
    prod.globalid AS "Global Name",
    longtodatec(inv.book_time, inv.product_center) AS "Book Time",
    inv.balance_quantity
FROM evolutionwellness.inventory_trans inv
JOIN evolutionwellness.products prod
    ON prod.center = inv.product_center
    AND prod.id = inv.product_id
JOIN Inventory i
	ON i.id = inv.Inventory
	AND i.center = inv.product_center
	
JOIN Centers c
    ON c.id = inv.product_center
WHERE inv.product_center IN (:Scope)
ORDER BY 
    inv.product_center,
    inv.product_id,
    inv.book_time DESC;
