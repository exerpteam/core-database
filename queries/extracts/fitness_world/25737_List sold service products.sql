-- This is the version from 2026-02-05
-- Ticket 46030
SELECT
    inv.CENTER "Scope",
    prod.NAME "Product name",
    invl.QUANTITY "Product sold",
    invl.TOTAL_AMOUNT "Product price",
    pu.TARGET_CENTER
FROM
    INVOICES inv
JOIN
    INVOICELINES invl
ON
    invl.CENTER = inv.CENTER
    AND invl.ID = inv.ID
JOIN
    PRODUCTS prod
ON
    prod.CENTER = invl.PRODUCTCENTER
    AND prod.ID = invl.PRODUCTID
    AND prod.PTYPE = 2
LEFT JOIN
    PRIVILEGE_USAGES pu
ON
    pu.DEDUCTION_KEY = inv.CENTER||'inv'||inv.id
WHERE
    inv.CENTER IN ($$scope$$)
    AND inv.TRANS_TIME BETWEEN $$fromDate$$ AND $$toDate$$
