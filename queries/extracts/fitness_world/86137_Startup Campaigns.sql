-- The extract is extracted from Exerp on 2026-02-08
--  
WITH
    PRODUCT_PRIVILEGE_PRICE AS
    (
        SELECT DISTINCT
            pg.GRANTER_ID,
            pp.PRICE_MODIFICATION_NAME AS PriceChangeType,
            CASE
                WHEN pp.PRICE_MODIFICATION_NAME = 'OVERRIDE'
                THEN pp.PRICE_MODIFICATION_AMOUNT
                WHEN pp.PRICE_MODIFICATION_NAME = 'PERCENTAGE_REBATE'
                THEN pr.price*pp.PRICE_MODIFICATION_AMOUNT
                WHEN pp.PRICE_MODIFICATION_NAME = 'FREE'
                THEN 0
                WHEN pp.PRICE_MODIFICATION_NAME = 'FIXED_REBATE'
                THEN pr.price-pp.PRICE_MODIFICATION_AMOUNT
                ELSE pr.price
            END AS price
        FROM
            PRIVILEGE_GRANTS pg
        JOIN
            PRODUCT_PRIVILEGES pp
        ON
            pp.PRIVILEGE_SET = pg.PRIVILEGE_SET
        AND pg.GRANTER_SERVICE = 'StartupCampaign'
        JOIN
            PRODUCTS pr
        ON
            pp.REF_GLOBALID = pr.GLOBALID
        AND pr.PTYPE IN (10,
                         5)
        AND pp.REF_TYPE = 'GLOBAL_PRODUCT'
    )
    ,
    PRODUCT_GROUP_PRICE AS
    (
        SELECT DISTINCT
            pg.GRANTER_ID,
            pp.PRICE_MODIFICATION_NAME AS PriceChangeType,
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
            END AS price
        FROM
            PRIVILEGE_GRANTS pg
        JOIN
            PRODUCT_PRIVILEGES pp
        ON
            pp.PRIVILEGE_SET = pg.PRIVILEGE_SET
            AND pg.GRANTER_SERVICE = 'StartupCampaign'
        JOIN
            PRODUCT_AND_PRODUCT_GROUP_LINK ppgl
        ON
            ppgl.PRODUCT_GROUP_ID = pp.REF_ID
        AND pp.REF_TYPE = 'PRODUCT_GROUP'
        JOIN
            PRODUCTS prod
        ON
            prod.CENTER = ppgl.PRODUCT_CENTER
        AND prod.ID = ppgl.PRODUCT_ID
        AND prod.PTYPE IN (10,
                           5)
    )
    ,
    AVAILABILITY AS
    (
        SELECT
            sc.ID,
            sc.NAME,
            sc.STARTTIME,
            sc.ENDTIME,
            sc.AVAILABLE_SCOPES
        FROM
            STARTUP_CAMPAIGN sc
        WHERE
            TRUNC(longtodate(sc.STARTTIME)) <= CURRENT_DATE
        AND longtodate(sc.ENDTIME) >= CURRENT_DATE
    )
    ,
    START_CAMPAIGNS AS
    (
        
        SELECT
             avail.ID,
             avail.NAME,
             avail.STARTTIME,
             avail.ENDTIME,
        
             unnest(string_to_array(AVAILABLE_SCOPES, ',')) AVAILABILITY
         FROM
             AVAILABILITY avail
    )
SELECT
    ID,
    NAME,
    STARTTIME,
    ENDTIME,
    SCOPE_TYPE,
    SCOPE_ID,
    MIN(PRODUCT_PRICE)
FROM
    (
        SELECT
            stcam.ID,
            stcam.NAME,
            stcam.STARTTIME,
            stcam.ENDTIME,
            SUBSTR(stcam.AVAILABILITY,1,1)                             AS SCOPE_TYPE,
            SUBSTR(stcam.AVAILABILITY, 2,LENGTH(stcam.AVAILABILITY)-1) AS SCOPE_ID,
            ppp.price                                                  AS PRODUCT_PRICE
        FROM
            START_CAMPAIGNS stcam
        JOIN
            PRODUCT_PRIVILEGE_PRICE ppp
        ON
            ppp.GRANTER_ID = stcam.ID
        UNION ALL
        SELECT
            stcam.ID,
            stcam.NAME,
            stcam.STARTTIME,
            stcam.ENDTIME,
            SUBSTR(stcam.AVAILABILITY,1,1)                             AS SCOPE_TYPE,
            SUBSTR(stcam.AVAILABILITY, 2,LENGTH(stcam.AVAILABILITY)-1) AS SCOPE_ID,
            pgp.price                                                  AS PRODUCT_PRICE
        FROM
            START_CAMPAIGNS stcam
        JOIN
            PRODUCT_GROUP_PRICE pgp
        ON
            pgp.GRANTER_ID = stcam.ID)t1
WHERE
    PRODUCT_PRICE IS NOT NULL
    
GROUP BY
    ID,
    NAME,
    STARTTIME,
    ENDTIME,
    SCOPE_TYPE,
    SCOPE_ID
