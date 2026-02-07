SELECT
    longToDate(inv.TRANS_TIME) trans_time,
    p.CENTER || 'p' || p.ID pid,
    prod.NAME,
    invl.QUANTITY,
    invl.TOTAL_AMOUNT amount_per_item,
    invl.TOTAL_AMOUNT * invl.QUANTITY total_amount
FROM
    SATS.PRIVILEGE_USAGES pu
JOIN SATS.PRIVILEGE_GRANTS pg
ON
    pg.ID = pu.GRANT_ID
JOIN SATS.INVOICELINES invl
ON
    invl.CENTER = pu.TARGET_CENTER
    AND invl.ID = pu.TARGET_ID
    AND invl.SUBID = pu.TARGET_SUBID
LEFT JOIN SATS.PRODUCTS prod
ON
    prod.CENTER = invl.PRODUCTCENTER
    AND prod.ID = invl.PRODUCTID
LEFT JOIN SATS.INVOICES inv
ON
    inv.CENTER = invl.CENTER
    AND inv.ID = invl.ID
LEFT JOIN SATS.PERSONS p
ON
    p.CENTER = inv.PAYER_CENTER
    AND p.ID = inv.PAYER_ID
WHERE
    pg.GRANTER_SERVICE = 'ReceiverGroup'
    AND pg.GRANTER_ID =
    (
        SELECT
            prg.ID
        FROM
            SATS.PRIVILEGE_RECEIVER_GROUPS prg
        WHERE
            prg.name = :campaignName
    )
    AND pu.TARGET_SERVICE = 'InvoiceLine'
    AND pu.STATE <> 'CANCELLED'