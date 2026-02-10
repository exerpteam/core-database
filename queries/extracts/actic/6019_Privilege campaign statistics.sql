-- The extract is extracted from Exerp on 2026-02-08
--  
SELECT
    inv.CENTER inv_center,
    inv.CENTER || 'inv' || inv.ID invID,
    longToDate(inv.TRANS_TIME) trans_time,
    p.CENTER || 'p' || p.ID pid,
    p.FULLNAME,
    prod.NAME,
    prod.GLOBALID,
    invl.PRODUCT_NORMAL_PRICE normal_price,
    invl.TOTAL_AMOUNT paid,
    ps.NAME
FROM
    PRIVILEGE_USAGES pu
JOIN PRIVILEGE_GRANTS pg
ON
    pg.ID = pu.GRANT_ID
JOIN PRIVILEGE_RECEIVER_GROUPS prg
ON
    prg.ID = pg.GRANTER_ID
    AND pg.GRANTER_SERVICE = 'ReceiverGroup'
JOIN INVOICELINES invl
ON
    invl.CENTER = pu.TARGET_CENTER
    AND invl.ID = pu.TARGET_ID
    AND invl.SUBID = pu.TARGET_SUBID
JOIN PRODUCTS prod
ON
    prod.CENTER = invl.PRODUCTCENTER
    AND prod.ID = invl.PRODUCTID
JOIN INVOICES inv
ON
    inv.CENTER = invl.CENTER
    AND inv.ID = invl.ID
JOIN PERSONS p
ON
    p.CENTER = inv.PAYER_CENTER
    AND p.ID = inv.PAYER_ID
JOIN PRIVILEGE_SETS ps
ON
    ps.ID = pg.PRIVILEGE_SET
WHERE
    prg.NAME = :campaign_name
    AND prg.RGTYPE = 'CAMPAIGN'
    AND inv.CENTER in (:center)
	AND inv.TRANS_TIME BETWEEN :longDateFrom AND :longDateTo