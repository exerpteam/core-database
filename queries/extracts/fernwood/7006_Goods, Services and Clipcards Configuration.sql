SELECT
        prod.CENTER,
        (CASE prod.PTYPE
                WHEN 1 THEN 'Retail'
                WHEN 2 THEN 'Service'
                WHEN 4 THEN 'Clipcard'
				WHEN 13 THEN 'Addon'
        END) AS product_type,
        c.NAME "center name",
        prod.GLOBALID "Global Name",
        prod.NAME "Product Name",
        prod.NEEDS_PRIVILEGE "Purchase Require Privilege",
        prod.SHOW_IN_SALE,
        prod.SHOW_ON_WEB,
        mpr.CACHED_PRODUCTPRICE "Top Level Price",
        prod.PRICE "Club Price",
        pg.NAME "sub primary Product Group",
        prod.BLOCKED,
apd.ID AS "Addon ID",
    apd.REQUIRED AS "Is Required Addon",
    aoSubProd.CACHED_PRODUCTNAME AS "Associated Subscription Addon",
    addReqPG.NAME AS "Addon Required Product Group"
FROM
        PRODUCTS prod
JOIN
        CENTERS c
        ON c.id = prod.CENTER
JOIN
        PRODUCT_GROUP pg
        ON pg.ID = prod.PRIMARY_PRODUCT_GROUP_ID
JOIN MASTERPRODUCTREGISTER mpr ON mpr.GLOBALID = prod.GLOBALID
LEFT JOIN ADD_ON_PRODUCT_DEFINITION apd ON apd.ID = mpr.ID
LEFT JOIN ADD_ON_TO_PRODUCT_GROUP_LINK aopglink ON aopglink.ADD_ON_PRODUCT_DEFINITION_ID = apd.ID
LEFT JOIN PRODUCT_GROUP addReqPG ON addReqPG.ID = aopglink.PRODUCT_GROUP_ID
LEFT JOIN SUBSCRIPTION_ADDON_PRODUCT sap ON sap.ADDON_PRODUCT_ID = apd.ID
LEFT JOIN MASTERPRODUCTREGISTER aoSubProd ON aoSubProd.ID = sap.SUBSCRIPTION_PRODUCT_ID
WHERE
        mpr.ID = mpr.DEFINITION_KEY
        AND 
        prod.PTYPE IN (1,2,4,13)
        --AND prod.BLOCKED = 0
		AND prod.center = :Scope
ORDER BY
        mpr.GLOBALID,
        prod.CENTER 