-- The extract is extracted from Exerp on 2026-02-08
-- Ticket 41538
SELECT
    prod.NAME,
    prod.GLOBALID,
    COUNT(invl.CENTER * invl.QUANTITY) items_sold
FROM
    FW.PRODUCTS prod
LEFT JOIN FW.INVOICELINES invl
ON
    invl.PRODUCTCENTER = prod.CENTER
    AND invl.PRODUCTID = prod.ID
LEFT JOIN FW.INVOICES inv
ON
    inv.CENTER = invl.CENTER
    AND inv.ID = invl.ID
WHERE
    prod.BLOCKED = 0
    AND prod.CENTER in (:scope)
    AND (inv.TRANS_TIME BETWEEN :fromDate AND :toDate or inv.center is null)
	and prod.PTYPE not in (5,10,12,6,7)
GROUP BY
    prod.NAME,
    prod.GLOBALID
HAVING
    COUNT(invl.CENTER * invl.QUANTITY) < :soldThreshold