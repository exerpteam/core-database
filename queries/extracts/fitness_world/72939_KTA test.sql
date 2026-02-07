-- This is the version from 2026-02-05
--  
SELECT
    centerid,
    centername,
    MIN(productprice) AS CURRENT_LOWEST_PRICE,
    core.price        AS NORMAL_PRICE
FROM
    (
        SELECT
            c.id   AS centerid,
            c.name AS centername,
            CASE
                WHEN pp.PRICE_MODIFICATION_NAME = 'OVERRIDE'
                THEN pp.PRICE_MODIFICATION_AMOUNT
                WHEN pp.PRICE_MODIFICATION_NAME = 'PERCENTAGE_REBATE'
                THEN prod.price*pp.PRICE_MODIFICATION_AMOUNT
                WHEN pp.PRICE_MODIFICATION_NAME = 'FREE'
                THEN 0
                WHEN pp.PRICE_MODIFICATION_NAME = 'FIXED_REBATE'
                THEN prod.price-pp.PRICE_MODIFICATION_AMOUNT
                ELSE prod.price
            END       AS productprice,
            prod.name AS productname
        FROM
            PRODUCTS prod
        JOIN
            CENTERS c
        ON
            c.id = prod.center
        JOIN
            PRODUCT_PRIVILEGES pp
        ON
            pp.ref_globalid = prod.GLOBALID
        AND pp.ref_type = 'GLOBAL_PRODUCT'
        AND prod.blocked = 0
        AND prod.PTYPE = 10
        JOIN
            PRIVILEGE_GRANTS pg
        ON
            pp.PRIVILEGE_SET = pg.PRIVILEGE_SET
        AND pg.GRANTER_SERVICE = 'StartupCampaign'
        JOIN
            STARTUP_CAMPAIGN sc
        ON
            sc.ID = pg.GRANTER_ID
        AND longtodate(sc.STARTTIME) <= CURRENT_DATE
        AND longtodate(sc.ENDTIME) >= CURRENT_DATE
        WHERE
            c.country = 'DK'
        AND c.id IN (:scope)
        AND c.id != 100
        AND c.name NOT LIKE 'OLD%'
        AND c.name NOT LIKE 'Pre%'
        UNION ALL
        SELECT
            c.id   AS centerid,
            c.name AS centername,
            CASE
                WHEN pp.PRICE_MODIFICATION_NAME = 'OVERRIDE'
                THEN pp.PRICE_MODIFICATION_AMOUNT
                WHEN pp.PRICE_MODIFICATION_NAME = 'PERCENTAGE_REBATE'
                THEN prod.price*pp.PRICE_MODIFICATION_AMOUNT
                WHEN pp.PRICE_MODIFICATION_NAME = 'FREE'
                THEN 0
                WHEN pp.PRICE_MODIFICATION_NAME = 'FIXED_REBATE'
                THEN prod.price-pp.PRICE_MODIFICATION_AMOUNT
                ELSE prod.price
            END       AS productprice,
            prod.name AS productname
        FROM
            PRODUCTS prod
        JOIN
            CENTERS c
        ON
            c.id = prod.center
        JOIN
            PRODUCT_AND_PRODUCT_GROUP_LINK ppgl
        ON
            prod.CENTER = ppgl.PRODUCT_CENTER
        AND prod.ID = ppgl.PRODUCT_ID
        AND prod.PTYPE = 10
        AND prod.blocked = 0
        JOIN
            PRODUCT_PRIVILEGES pp
        ON
            pp.REF_ID = ppgl.PRODUCT_GROUP_ID
        AND pp.REF_TYPE = 'PRODUCT_GROUP'
        JOIN
            PRIVILEGE_GRANTS pg
        ON
            pp.PRIVILEGE_SET = pg.PRIVILEGE_SET
        AND pg.GRANTER_SERVICE = 'StartupCampaign'
        JOIN
            STARTUP_CAMPAIGN sc
        ON
            sc.ID = pg.GRANTER_ID
        AND longtodate(sc.STARTTIME) <= CURRENT_DATE
        AND longtodate(sc.ENDTIME) >= CURRENT_DATE

        WHERE
            c.country = 'DK'
        AND c.id IN (:scope)
        AND c.id != 100
        AND c.name NOT LIKE 'OLD%'
        AND c.name NOT LIKE 'Pre%')
JOIN
    PRODUCTS Core
ON
    core.center = centerid
AND core.blocked = 0
AND core.PTYPE = 10
AND core.GLOBALID LIKE 'CORE____'
GROUP BY
    centerid,
    centername,
    core.price
ORDER BY
    centerid