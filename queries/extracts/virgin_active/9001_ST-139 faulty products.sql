SELECT
    p.CENTER || 'prod' || p.ID prod_id,
    p.NAME,
    p.BLOCKED,
    p.GLOBALID,
    mpr.SCOPE_TYPE,
    nvl2(mpr.SCOPE_TYPE,0,1) UK_PRODUCT,
    nvl2(invl.CENTER,1,0)    has_been_sold,
    invl.CENTER
FROM
    PRODUCTS p
LEFT JOIN
    MASTERPRODUCTREGISTER mpr
ON
    mpr.GLOBALID = p.GLOBALID
    AND ((
            mpr.SCOPE_TYPE = 'A'
            AND mpr.SCOPE_ID IN (1,24))
        OR (
            mpr.SCOPE_TYPE = 'C'
            AND mpr.SCOPE_ID = p.CENTER) )
LEFT JOIN
    INVOICELINES invl
ON
    invl.PRODUCTCENTER = p.CENTER
    AND invl.PRODUCTID = p.ID
WHERE
    p.CENTER = 100
    AND nvl2(mpr.SCOPE_TYPE,0,1) = 1