-- This is the version from 2026-02-05
-- Ticket 37855
SELECT
inv.PAYER_CENTER || 'p' || inv.PAYER_ID pid ,
longToDate(inv.TRANS_TIME) TRANS_TIME,
prod.NAME
FROM
FW.INVOICELINES invl
JOIN FW.INVOICES inv
ON
inv.CENTER = invl.CENTER
AND inv.ID = invl.ID
JOIN FW.PRODUCTS prod
ON
    prod.CENTER = invl.PRODUCTCENTER
    AND prod.ID = invl.PRODUCTID
WHERE
prod.GLOBALID IN ('NON_LOCAL_CHECKIN_FEE', 'CLUB_CHECKIN_FEE')
and inv.TRANS_TIME between :longStartDate and :longEndDate
and inv.CENTER in (:scope)