SELECT DISTINCT
    /*inv.CENTER || 'inv' || inv.id ind_id,*/
    longToDateC(inv.TRANS_TIME,inv.center) "Sales Date",
    p.FIRSTNAME,
    p.LASTNAME,
    c.ID   center_id,
    c.NAME center_name,
    /*pgr.NAME PRIMARY_PRODUCT_GROUP,*/
    prod.NAME         PRODUCT_NAME,
    invl.TOTAL_AMOUNT "Cost",
    invl.QUANTITY     "Quantity",
    CASE
        WHEN prod.PTYPE = 13
        THEN 'Addon'
        WHEN prod.PTYPE = 4
        THEN 'Clip card'
        ELSE 'Unknown'
    END AS "Product Type",
    CASE
        WHEN prod.PTYPE = 13
        THEN ps.FREQUENCY_RESTRICTION_COUNT
        WHEN prod.PTYPE = 4
        THEN cct.CLIP_COUNT
        ELSE -1
    END AS sessions
FROM
    INVOICELINES invl
JOIN
    INVOICES inv
ON
    inv.CENTER = invl.CENTER
    AND inv.ID = invl.ID
JOIN
    PERSONS p
ON
    p.CENTER = inv.PAYER_CENTER
    AND p.ID = inv.PAYER_ID
JOIN
    CENTERS c
ON
    c.ID = p.CENTER
JOIN
    PRODUCTS prod
ON
    prod.CENTER = invl.PRODUCTCENTER
    AND prod.ID = invl.PRODUCTID
JOIN
    PRODUCT_GROUP pgr
ON
    pgr.ID = prod.PRIMARY_PRODUCT_GROUP_ID
    /* Gives the sessions for normal clip cards */
LEFT JOIN
    CLIPCARDTYPES cct
ON
    cct.CENTER = prod.CENTER
    AND cct.id = prod.ID
LEFT JOIN
    MASTERPRODUCTREGISTER mpr
ON
    mpr.GLOBALID = prod.GLOBALID
LEFT JOIN
    PRIVILEGE_GRANTS pg
ON
    pg.GRANTER_ID = mpr.ID
    AND pg.GRANTER_SERVICE = 'Addon'
    AND pg.VALID_TO IS NULL
LEFT JOIN
    PRIVILEGE_SETS ps
ON
    ps.id = pg.PRIVILEGE_SET
WHERE
    /* and pgr.name IN ('PT Clipcards','PT DD Master','Personal Training') */
    prod.PTYPE IN (4,13)
    AND (
        pgr.id = 271
        OR pgr.PARENT_PRODUCT_GROUP_ID = 271)
    AND prod.center IN(:scope)
    AND (
        cct.CENTER IS NOT NULL
        OR ps.FREQUENCY_RESTRICTION_COUNT IS NOT NULL )
    AND inv.TRANS_TIME BETWEEN exerpro.dateToLong(TO_CHAR(TRUNC($$referenceDate$$,'MM'),'YYYY-MM-dd HH24:MI')) AND ((
            1000*60*60*24) - 1) + exerpro.dateToLong(TO_CHAR(last_day(TRUNC($$referenceDate$$,'MM')),'YYYY-MM-dd HH24:MI'))