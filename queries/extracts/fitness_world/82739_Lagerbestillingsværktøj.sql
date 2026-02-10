-- The extract is extracted from Exerp on 2026-02-08
--  
WITH
    product_sales7 AS 
    (
        SELECT DISTINCT
            it_prod7.PRODUCT_CENTER,
            it_prod7.PRODUCT_ID,
            SUM(it_prod7.QUANTITY) * -1 AS sales,
            MAX(it_prod7.ENTRY_TIME) AS max_entry_time
        FROM
            INVENTORY_TRANS it_prod7
        WHERE
            it_prod7.TYPE IN ('SALE',
                              'RETURN')
        AND it_prod7.ENTRY_TIME >= CAST(datetolong(TO_CHAR(CURRENT_DATE - :DAYS,
            'YYYY-MM-DD HH24:MI')) AS bigint)
        GROUP BY
            it_prod7.PRODUCT_CENTER,
            it_prod7.PRODUCT_ID
    )
SELECT DISTINCT
    pr.NAME             AS "Produkt navn",
    it.BALANCE_QUANTITY AS "Lager beholdning",
    ps7.sales           AS "Antal solgte varer"
FROM
    INVENTORY i
JOIN
    INVENTORY_TRANS it
ON
    it.INVENTORY = i.ID
JOIN
    PRODUCTS pr
ON
    it.PRODUCT_CENTER = pr.CENTER
AND it.PRODUCT_ID = pr.ID
JOIN
    product_sales7 ps7
ON
    it.PRODUCT_CENTER = ps7.PRODUCT_CENTER
AND it.PRODUCT_ID = ps7.PRODUCT_ID
WHERE
    it.ENTRY_TIME = ps7.max_entry_time
AND i.CENTER = :CENTER
AND pr.BLOCKED = 0
AND pr.NAME NOT LIKE 'PT%';
