SELECT distinct
    longToDate(inv.TRANS_TIME) TRANS_TIME,
    mpr.CACHED_PRODUCTNAME,
    inv.CENTER || 'inv' || inv.ID inv_id,
    invl.SUBID                    invl_sub_id,
    p.CENTER || 'p' || p.ID       pid,
    p.FULLNAME,
    invl.TOTAL_AMOUNT,
    invl.QUANTITY,
    prod.NAME,
    prod.EXTERNAL_ID,
    prod.PRICE,
    prod.COST_PRICE
FROM
    INVOICELINES invl
LEFT JOIN
    PRIVILEGE_USAGES pu
ON
    invl.CENTER = pu.TARGET_CENTER
    AND invl.ID = pu.TARGET_ID
    AND invl.SUBID = pu.TARGET_SUBID
    AND pu.TARGET_SERVICE = 'InvoiceLine'
    AND pu.PRIVILEGE_TYPE = 'PRODUCT'
    AND pu.STATE = 'USED'
LEFT JOIN
    PRODUCT_PRIVILEGES pp
ON
    pu.PRIVILEGE_ID = pp.id
    AND pp.REF_TYPE = 'PRODUCT_GROUP'
    AND pp.PRICE_MODIFICATION_NAME = 'FREE'
    AND pp.REF_ID = 810
LEFT JOIN
    PRIVILEGE_GRANTS pg
ON
    pg.ID = pu.GRANT_ID
    AND pg.GRANTER_SERVICE = 'GlobalSubscription'
JOIN
    INVOICES inv
ON
    inv.CENTER = invl.CENTER
    AND inv.ID = invl.ID
JOIN
    PRODUCTS prod
ON
    prod.CENTER = invl.PRODUCTCENTER
    AND prod.ID = invl.PRODUCTID
LEFT JOIN
    PERSONS p
ON
    p.CENTER = inv.PAYER_CENTER
    AND p.ID = inv.PAYER_ID
LEFT JOIN
    MASTERPRODUCTREGISTER mpr
ON
    mpr.id= pg.GRANTER_ID
WHERE
   invl.CENTER IN (301,302,303)
   and prod.PRIMARY_PRODUCT_GROUP_ID = 810