SELECT
    t.CenterName, t.InventoryName, t.ProductName, t.EXTERNAL_ID, t.BARCODE, t.BALANCE_QUANTITY, t.BALANCE_VALUE
FROM
    (
        SELECT c.name As CenterName, i.name as InventoryName, p.name as ProductName, p.EXTERNAL_ID, ei.IDENTITY AS Barcode, it.COMENT As Description, it.BALANCE_QUANTITY, it.BALANCE_VALUE,
            rank() over (partition BY it.INVENTORY, it.PRODUCT_CENTER,it.PRODUCT_ID ORDER BY it.ENTRY_TIME DESC) AS rnk
        FROM
           INVENTORY i
        JOIN
           CENTERS c
        ON 
           i.CENTER = c.ID
        JOIN
           INVENTORY_TRANS it
        ON
           it.INVENTORY = i.ID   
        JOIN
           PRODUCTS p
        ON
           p.CENTER = it.PRODUCT_CENTER AND p.ID = it.PRODUCT_ID 
        JOIN 
           ENTITYIDENTIFIERS ei  
        ON   
           p.GLOBALID = ei.REF_GLOBALID AND ei.IDMETHOD = 1  AND ei.REF_TYPE in (3,4)
        WHERE c.ID in (:scope)
            ) t
WHERE
    rnk = 1