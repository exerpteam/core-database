-- This is the version from 2026-02-05
--  

--86337
WITH recursive
     START_QUERY AS
     (
         SELECT
             a.id,
             a.name,
             a.parent,
             pa.name AS parentname,
             ac.CENTER,
             c.name AS centername,
             c.zipcode
         FROM
             AREAS a
         LEFT JOIN
             AREA_CENTERS ac
         ON
             a.ID = ac.AREA
         LEFT JOIN
             areas pa
         ON
             a.parent = pa.id
         LEFT JOIN
             centers c
         ON
             ac.center = c.id
     )
     ,
     sub_area
     (
         id,
         name,
         parent,
         parentname,
         center,
         centername,
         zipcode
     ) AS
     (  SELECT
             Sa.id,
             Sa.name,
             Sa.parent,
             Sa.parentname,
             sa.center,
             sa.centername,
             sa.zipcode
         FROM
             START_QUERY sa
         
         UNION ALL
       
             SELECT
             a.id,
             a.name,
             a.parent,
             a.name AS parentname,
             sa.center,
             sa.centername,
             c.zipcode
         FROM
             sub_area sa
         JOIN
             areas a
         ON
             sa.PARENT = a.id
         JOIN
             centers c
         ON
             sa.center = c.id)
    ,
    TEMP_TABLE AS
    (
        SELECT
            *
        FROM
            sub_area
    )
    ,
    list_products AS
    (
        SELECT DISTINCT
            mpr.id        AS mprId,
            mpr.globalid  AS globalid,
            pa.scope_type AS AREA_TYPE,
            pa.scope_id   AS AREA_ID,
            p.price       AS price,
            p.name        AS pname
            -- regexp_substr(pa.SCOPE_TYPE, 'ASS\\[([ATCG])[0-9]+\\]',1,1,NULL,1)              AS
            -- AREA_TYPE,
            -- CAST(regexp_substr(pa.SCOPE_ID, 'ASS\\[[ATCG]([0-9]+)\\]',1,1,NULL,1) AS INT) AS
            -- AREA_ID
        FROM
            MASTERPRODUCTREGISTER mpr
        JOIN
            products p
        ON
            p.globalid = mpr.globalid
        AND mpr.STATE = 'ACTIVE'
        JOIN
            PRODUCT_AND_PRODUCT_GROUP_LINK ppgl
        ON
            ppgl.PRODUCT_CENTER = p.CENTER
        AND ppgl.PRODUCT_ID = p.ID
        JOIN
            PRODUCT_GROUP pg
        ON
            pg.ID = ppgl.PRODUCT_GROUP_ID
        AND pg.ID = 32801
        JOIN
            PRODUCT_AVAILABILITY pa
        ON
            pa.PRODUCT_MASTER_KEY = mpr.id
        WHERE
            p.center IN (:scope)
        AND p.PTYPE = 10
        AND mpr.globalid NOT LIKE 'CORE_OFFPEAK%'
        AND mpr.globalid NOT LIKE 'PLUS_FRIEND'
    )
    ,
    CORE_SUB AS
    (
        SELECT DISTINCT
            *
        FROM
            (
                SELECT
                    pname         AS NAME,
                    tt.center     AS CENTER_ID,
                    tt.centername AS CENTER_NAME,
                    price         AS PRICE,
                    globalid      AS globalid
                FROM
                    list_products psl
                JOIN
                    TEMP_TABLE tt
                ON
                    psl.AREA_ID = tt.ID
                WHERE
                    psl.AREA_TYPE IN ( 'A',
                                      'T')
                AND tt.id IS NOT NULL
                AND tt.center IS NOT NULL
                UNION ALL
                SELECT DISTINCT
                    PNAME         AS NAME,
                    tt.center     AS CENTER_ID,
                    tt.centername AS CENTER_NAME,
                    price         AS PRICE,
                    globalid      AS globalid
                FROM
                    list_products psl
                JOIN
                    TEMP_TABLE tt
                ON
                    psl.AREA_ID = tt.CENTER
                WHERE
                    psl.AREA_TYPE = 'C'
                AND tt.id IS NOT NULL
                AND tt.center IS NOT NULL
                UNION ALL
                SELECT DISTINCT
                    PNAME         AS NAME,
                    tt.center     AS CENTER_ID,
                    tt.centername AS CENTER_NAME,
                    price         AS PRICE,
                    globalid      AS globalid
                FROM
                    list_products psl
                CROSS JOIN
                    TEMP_TABLE tt
                WHERE
                    psl.AREA_TYPE = 'G'
                AND tt.center IS NOT NULL
                AND tt.id IS NOT NULL) t1
        WHERE
            CENTER_ID != 100
        AND CENTER_NAME NOT LIKE 'OLD%'
        AND globalid LIKE 'CORE_____________'
    )
    ,
    ALL_SUB AS
    (
        SELECT DISTINCT
            *
        FROM
            (
                SELECT
                    pname         AS NAME,
                    tt.center     AS CENTER_ID,
                    tt.centername AS CENTER_NAME,
                    price         AS PRICE,
                    globalid      AS globalid
                FROM
                    list_products psl
                JOIN
                    TEMP_TABLE tt
                ON
                    psl.AREA_ID = tt.ID
                WHERE
                    psl.AREA_TYPE IN ( 'A',
                                      'T')
                AND tt.id IS NOT NULL
                AND tt.center IS NOT NULL
                UNION ALL
                SELECT DISTINCT
                    PNAME         AS NAME,
                    tt.center     AS CENTER_ID,
                    tt.centername AS CENTER_NAME,
                    price         AS PRICE,
                    globalid      AS globalid
                FROM
                    list_products psl
                JOIN
                    TEMP_TABLE tt
                ON
                    psl.AREA_ID = tt.CENTER
                WHERE
                    psl.AREA_TYPE = 'C'
                AND tt.id IS NOT NULL
                AND tt.center IS NOT NULL
                UNION ALL
                SELECT DISTINCT
                    PNAME         AS NAME,
                    tt.center     AS CENTER_ID,
                    tt.centername AS CENTER_NAME,
                    price         AS PRICE,
                    globalid      AS globalid
                FROM
                    list_products psl
                CROSS JOIN
                    TEMP_TABLE tt
                WHERE
                    psl.AREA_TYPE = 'G'
                AND tt.center IS NOT NULL
                AND tt.id IS NOT NULL)t1
        WHERE
            CENTER_ID != 100
        AND CENTER_NAME NOT LIKE 'OLD%'
        AND CENTER_ID in (:scope)
    )
    ,
    AVAILABILITY AS
    (
        SELECT
            sc.ID,
            sc.NAME,
            sc.STARTTIME,
            sc.ENDTIME,
            sc.AVAILABLE_SCOPES,
            sc.PLUGIN_CODES_NAME
        FROM
            STARTUP_CAMPAIGN sc
        WHERE
            sc.STATE = 'ACTIVE'
        AND sc.PLUGIN_CODES_NAME = 'NO_CODES'
        AND sc.STARTTIME <= CAST(dateToLongC(getCenterTime(100), 100) AS bigint)
        AND sc.ENDTIME >= CAST(dateToLongC(getCenterTime(100), 100) AS bigint)
    )
    ,
    START_CAMPAIGNS AS
    (
        SELECT
             avail.ID,
             avail.NAME,
             avail.STARTTIME,
             avail.ENDTIME,
             avail.PLUGIN_CODES_NAME,
             unnest(string_to_array(AVAILABLE_SCOPES, ',')) AVAILABILITY
         FROM
             AVAILABILITY avail 
    )
    ,
    STARTUP_CAMPAIGNS AS
    (
        SELECT DISTINCT
            stcam.ID,
            stcam.NAME,
            stcam.STARTTIME,
            stcam.ENDTIME,
            SUBSTR(stcam.AVAILABILITY,1,1)                             AS SCOPE_TYPE,
            SUBSTR(stcam.AVAILABILITY, 2,LENGTH(stcam.AVAILABILITY)-1) AS SCOPE_ID
        FROM
            START_CAMPAIGNS stcam
    )
    ,
    AVAILABILITY_PRIV AS
    (
        SELECT
            prg.ID,
            prg.NAME,
            prg.STARTTIME,
            prg.ENDTIME,
            prg.AVAILABLE_SCOPES,
            prg.PLUGIN_CODES_NAME
        FROM
            PRIVILEGE_RECEIVER_GROUPS prg
        WHERE
            prg.RGTYPE = 'CAMPAIGN'
        AND prg.BLOCKED = 0
        AND prg.PLUGIN_CODES_NAME = 'NO_CODES'
        AND prg.ENDTIME >= CAST(dateToLongC(getCenterTime(100), 100) AS bigint)
        AND prg.STARTTIME <= CAST(dateToLongC(getCenterTime(100), 100) AS bigint)
        AND (
                prg.WEB_TEXT LIKE 'L-%'
            OR  prg.WEB_TEXT LIKE 'N-%')
    )
    ,
    PRIV_CAMPAIGNS AS
    (
       SELECT
             avail_priv.ID,
             avail_priv.NAME,
             avail_priv.STARTTIME,
             avail_priv.ENDTIME,
             avail_priv.PLUGIN_CODES_NAME,
             unnest(string_to_array(AVAILABLE_SCOPES, ',')) AVAILABILITY
         FROM
             AVAILABILITY_PRIV avail_priv 
    )
    ,
    PRIVILEGE_CAMPAIGNS AS
    (
        SELECT DISTINCT
            prcam.ID,
            prcam.NAME,
            prcam.STARTTIME,
            prcam.ENDTIME,
            SUBSTR(prcam.AVAILABILITY,1,1)                             AS SCOPE_TYPE,
            SUBSTR(prcam.AVAILABILITY, 2,LENGTH(prcam.AVAILABILITY)-1) AS SCOPE_ID
        FROM
            PRIV_CAMPAIGNS prcam
    )
SELECT
    centerid,
    centername,
    REPLACE(REPLACE(REPLACE(TO_CHAR(MIN(productprice),'999G999G990D00'),'.','-'),',','.'),'-',',') AS CURRENT_LOWEST_PRICE
    ,
    REPLACE(REPLACE(REPLACE(TO_CHAR(core.price,'999G999G990D00'),'.','-'),',','.'),'-',',')        AS NORMAL_PRICE,
    REPLACE(REPLACE(REPLACE(TO_CHAR(MIN(joiningprice),'999G999G990D00'),'.','-'),',','.'),'-',',') AS
    CURRENT_LOWEST_JOINING_PRICE,
    REPLACE(REPLACE(REPLACE(TO_CHAR(MIN(joining.price),'999G999G990D00'),'.','-'),',','.'),'-',',') AS
    NORMAL_JOINING_PRICE
FROM
    (
        SELECT
            CENTERID   AS centerid,
            CENTERNAME AS centername,
           ( CASE
                WHEN pp.PRICE_MODIFICATION_NAME = 'OVERRIDE'
                THEN pp.PRICE_MODIFICATION_AMOUNT
                WHEN pp.PRICE_MODIFICATION_NAME = 'PERCENTAGE_REBATE'
                THEN prod.price-(prod.price*pp.PRICE_MODIFICATION_AMOUNT)
                WHEN pp.PRICE_MODIFICATION_NAME = 'FREE'
                THEN 0
                WHEN pp.PRICE_MODIFICATION_NAME = 'FIXED_REBATE'
                THEN prod.price-pp.PRICE_MODIFICATION_AMOUNT
                ELSE prod.price
            END  )::numeric     AS productprice,
            prod.name AS productname,
            NULL      AS joiningprice,
            NULL      AS joiningname
        FROM
            (
                SELECT
                    c.id       AS CENTERID,
                    c.name     AS CENTERNAME,
                    sc_area.ID AS START_CAMP_ID
                FROM
                    centers c
                JOIN
                    TEMP_TABLE tt
                ON
                    tt.CENTER = c.ID
                AND tt.ID IS NOT NULL
                AND tt.CENTER IS NOT NULL
                LEFT JOIN
                    STARTUP_CAMPAIGNS sc_area
                ON
                    sc_area.SCOPE_ID = tt.ID::varchar
                AND sc_area.SCOPE_TYPE IN ('A',
                                           'T')
                AND tt.ID IS NOT NULL
                WHERE
                    c.country = 'DK'
                AND c.id IN (:scope)
                AND c.id != 100
                AND c.name NOT LIKE 'OLD%'
                AND c.name NOT LIKE 'Pre%'
                UNION ALL
                SELECT
                    c.id         AS CENTERID,
                    c.name       AS CENTERNAME,
                    sc_center.id AS START_CAMP_ID
                FROM
                    centers c
                LEFT JOIN
                    STARTUP_CAMPAIGNS sc_center
                ON
                    sc_center.SCOPE_ID = c.ID::varchar
                AND sc_center.SCOPE_TYPE = 'C'
                WHERE
                    c.country = 'DK'
                AND c.id IN (:scope)
                AND c.id != 100
                AND c.name NOT LIKE 'OLD%'
                AND c.name NOT LIKE 'Pre%' )t1
        JOIN
            PRIVILEGE_GRANTS pg
        ON
            pg.GRANTER_ID = START_CAMP_ID
        AND (
                pg.VALID_TO IS NULL
            OR  pg.VALID_TO >= CAST(dateToLongC(getCenterTime(100), 100) AS bigint))
        AND pg.GRANTER_SERVICE = 'StartupCampaign'
        JOIN
            PRODUCT_PRIVILEGES pp
        ON
            pp.PRIVILEGE_SET = pg.PRIVILEGE_SET
            AND (pp.valid_to > CAST(dateToLongC(getCenterTime(100), 100) AS bigint) OR pp.valid_to is null)
        JOIN
            PRODUCTS prod
        ON
            pp.ref_globalid = prod.GLOBALID
        AND pp.ref_type = 'GLOBAL_PRODUCT'
        AND prod.blocked = 0
        AND prod.PTYPE = 10
        JOIN
            ALL_SUB sub
        ON
            sub.center_id = prod.center
        AND sub.globalid = prod.globalid
        AND sub.center_id = CENTERID
        UNION ALL
        SELECT
            CENTERID   AS centerid,
            CENTERNAME AS centername,
          (  CASE
                WHEN pp.PRICE_MODIFICATION_NAME = 'OVERRIDE'
                THEN pp.PRICE_MODIFICATION_AMOUNT
                WHEN pp.PRICE_MODIFICATION_NAME = 'PERCENTAGE_REBATE'
                THEN prod.price-(prod.price*pp.PRICE_MODIFICATION_AMOUNT)
                WHEN pp.PRICE_MODIFICATION_NAME = 'FREE'
                THEN 0
                WHEN pp.PRICE_MODIFICATION_NAME = 'FIXED_REBATE'
                THEN prod.price-pp.PRICE_MODIFICATION_AMOUNT
                ELSE prod.price
            END   )::numeric    AS productprice,
            prod.name AS productname,
            (NULL)::numeric      AS joiningprice,
            NULL      AS joiningname
        FROM
            (
                SELECT
                    c.id       AS CENTERID,
                    c.name     AS CENTERNAME,
                    sc_area.ID AS START_CAMP_ID
                FROM
                    centers c
                JOIN
                    TEMP_TABLE tt
                ON
                    tt.CENTER = c.ID
                AND tt.ID IS NOT NULL
                AND tt.CENTER IS NOT NULL
                LEFT JOIN
                    STARTUP_CAMPAIGNS sc_area
                ON
                    sc_area.SCOPE_ID = tt.ID::varchar
                AND sc_area.SCOPE_TYPE IN ('A',
                                           'T')
                AND tt.ID IS NOT NULL
                WHERE
                    c.country = 'DK'
                AND c.id IN (:scope)
                AND c.id != 100
                AND c.name NOT LIKE 'OLD%'
                AND c.name NOT LIKE 'Pre%'
                UNION ALL
                SELECT
                    c.id         AS CENTERID,
                    c.name       AS CENTERNAME,
                    sc_center.id AS START_CAMP_ID
                FROM
                    centers c
                LEFT JOIN
                    STARTUP_CAMPAIGNS sc_center
                ON
                    sc_center.SCOPE_ID = c.ID::varchar
                AND sc_center.SCOPE_TYPE = 'C'
                WHERE
                    c.country = 'DK'
                AND c.id IN (:scope)
                AND c.id != 100
                AND c.name NOT LIKE 'OLD%'
                AND c.name NOT LIKE 'Pre%' )t1
        JOIN
            PRIVILEGE_GRANTS pg
        ON
            pg.GRANTER_ID = START_CAMP_ID
        AND (
                pg.VALID_TO IS NULL
            OR  pg.VALID_TO >= CAST(dateToLongC(getCenterTime(100), 100) AS bigint))
        AND pg.GRANTER_SERVICE = 'StartupCampaign'
        JOIN
            PRODUCT_PRIVILEGES pp
        ON
            pp.PRIVILEGE_SET = pg.PRIVILEGE_SET
            AND (pp.valid_to > CAST(dateToLongC(getCenterTime(100), 100) AS bigint) OR pp.valid_to is null)
        JOIN
            PRODUCT_AND_PRODUCT_GROUP_LINK ppgl
        ON
            pp.REF_ID = ppgl.PRODUCT_GROUP_ID
        AND pp.REF_TYPE = 'PRODUCT_GROUP'
        JOIN
            PRODUCTS prod
        ON
            prod.CENTER = ppgl.PRODUCT_CENTER
        AND prod.ID = ppgl.PRODUCT_ID
        AND prod.PTYPE = 10
        AND prod.blocked = 0
        JOIN
            ALL_SUB sub
        ON
            sub.center_id = prod.center
        AND sub.globalid = prod.globalid
        AND sub.center_id = CENTERID
        UNION ALL
        SELECT
            CENTERID   AS centerid,
            CENTERNAME AS centername,
            NULL       AS productprice,
            NULL       AS productname,
            (CASE
                WHEN pp.PRICE_MODIFICATION_NAME = 'OVERRIDE'
                THEN pp.PRICE_MODIFICATION_AMOUNT
                WHEN pp.PRICE_MODIFICATION_NAME = 'PERCENTAGE_REBATE'
                THEN prod.price-(prod.price*pp.PRICE_MODIFICATION_AMOUNT)
                WHEN pp.PRICE_MODIFICATION_NAME = 'FREE'
                THEN 0
                WHEN pp.PRICE_MODIFICATION_NAME = 'FIXED_REBATE'
                THEN prod.price-pp.PRICE_MODIFICATION_AMOUNT
                ELSE prod.price
            END )::numeric      AS joiningprice,
            prod.name AS joiningname
        FROM
            (
                SELECT
                    c.id       AS CENTERID,
                    c.name     AS CENTERNAME,
                    pr_area.ID AS PRIV_CAMP_ID
                FROM
                    centers c
                JOIN
                    TEMP_TABLE tt
                ON
                    tt.CENTER = c.ID
                AND tt.ID IS NOT NULL
                AND tt.CENTER IS NOT NULL
                LEFT JOIN
                    PRIVILEGE_CAMPAIGNS pr_area
                ON
                    pr_area.SCOPE_ID = tt.ID::varchar
                AND pr_area.SCOPE_TYPE IN ('A',
                                           'T')
                AND tt.ID IS NOT NULL
                WHERE
                    c.country = 'DK'
                AND c.id IN (:scope)
                AND c.id != 100
                AND c.name NOT LIKE 'OLD%'
                AND c.name NOT LIKE 'Pre%'
                UNION ALL
                SELECT
                    c.id         AS CENTERID,
                    c.name       AS CENTERNAME,
                    pr_center.id AS PRIV_CAMP_ID
                FROM
                    centers c
                LEFT JOIN
                    PRIVILEGE_CAMPAIGNS pr_center
                ON
                    pr_center.SCOPE_ID = c.ID::varchar
                AND pr_center.SCOPE_TYPE = 'C'
                WHERE
                    c.country = 'DK'
                AND c.id IN (:scope)
                AND c.id != 100
                AND c.name NOT LIKE 'OLD%'
                AND c.name NOT LIKE 'Pre%' )t1
        JOIN
            PRIVILEGE_GRANTS pg
        ON
            pg.GRANTER_ID = PRIV_CAMP_ID
        AND (
                pg.VALID_TO IS NULL
            OR  pg.VALID_TO >= CAST(dateToLongC(getCenterTime(100), 100) AS bigint))
        AND pg.GRANTER_SERVICE = 'ReceiverGroup'
        JOIN
            PRODUCT_PRIVILEGES pp
        ON
            pp.PRIVILEGE_SET = pg.PRIVILEGE_SET
            AND (pp.valid_to > CAST(dateToLongC(getCenterTime(100), 100) AS bigint) OR pp.valid_to is null)
        JOIN
            PRODUCTS prod
        ON
            pp.ref_globalid = prod.GLOBALID
        AND pp.ref_type = 'GLOBAL_PRODUCT'
        AND prod.blocked = 0
        AND prod.PTYPE = 5
        UNION ALL
        SELECT
            CENTERID   AS centerid,
            CENTERNAME AS centername,
            NULL       AS productprice,
            NULL       AS productname,
           ( CASE
                WHEN pp.PRICE_MODIFICATION_NAME = 'OVERRIDE'
                THEN pp.PRICE_MODIFICATION_AMOUNT
                WHEN pp.PRICE_MODIFICATION_NAME = 'PERCENTAGE_REBATE'
                THEN prod.price-(prod.price*pp.PRICE_MODIFICATION_AMOUNT)
                WHEN pp.PRICE_MODIFICATION_NAME = 'FREE'
                THEN 0
                WHEN pp.PRICE_MODIFICATION_NAME = 'FIXED_REBATE'
                THEN prod.price-pp.PRICE_MODIFICATION_AMOUNT
                ELSE prod.price
            END  )::numeric     AS joiningprice,
            prod.name AS joiningname
        FROM
            (
                SELECT
                    c.id       AS CENTERID,
                    c.name     AS CENTERNAME,
                    pr_area.ID AS PRIV_CAMP_ID
                FROM
                    centers c
                JOIN
                    TEMP_TABLE tt
                ON
                    tt.CENTER = c.ID
                AND tt.ID IS NOT NULL
                AND tt.CENTER IS NOT NULL
                LEFT JOIN
                    PRIVILEGE_CAMPAIGNS pr_area
                ON
                    pr_area.SCOPE_ID = tt.ID::varchar
                AND pr_area.SCOPE_TYPE IN ('A',
                                           'T')
                AND tt.ID IS NOT NULL
                WHERE
                    c.country = 'DK'
                AND c.id IN (:scope)
                AND c.id != 100
                AND c.name NOT LIKE 'OLD%'
                AND c.name NOT LIKE 'Pre%'
                UNION ALL
                SELECT
                    c.id         AS CENTERID,
                    c.name       AS CENTERNAME,
                    pr_center.id AS PRIV_CAMP_ID
                FROM
                    centers c
                LEFT JOIN
                    PRIVILEGE_CAMPAIGNS pr_center
                ON
                    pr_center.SCOPE_ID = c.ID::varchar
                AND pr_center.SCOPE_TYPE = 'C'
                WHERE
                    c.country = 'DK'
                AND c.id IN (:scope)
                AND c.id != 100
                AND c.name NOT LIKE 'OLD%'
                AND c.name NOT LIKE 'Pre%' )t1
        JOIN
            PRIVILEGE_GRANTS pg
        ON
            pg.GRANTER_ID = PRIV_CAMP_ID
        AND (
                pg.VALID_TO IS NULL
            OR  pg.VALID_TO >= CAST(dateToLongC(getCenterTime(100), 100) AS bigint))
        AND pg.GRANTER_SERVICE = 'ReceiverGroup'
        JOIN
            PRODUCT_PRIVILEGES pp
        ON
            pp.PRIVILEGE_SET = pg.PRIVILEGE_SET
            AND (pp.valid_to > CAST(dateToLongC(getCenterTime(100), 100) AS bigint) OR pp.valid_to is null)
        JOIN
            PRODUCT_AND_PRODUCT_GROUP_LINK ppgl
        ON
            pp.REF_ID = ppgl.PRODUCT_GROUP_ID
        AND pp.REF_TYPE = 'PRODUCT_GROUP'
        JOIN
            PRODUCTS prod
        ON
            prod.CENTER = ppgl.PRODUCT_CENTER
        AND prod.ID = ppgl.PRODUCT_ID
        AND prod.PTYPE = 5
        AND prod.blocked = 0 ) t1
JOIN
    CORE_SUB core
ON
    core.center_id = centerid
LEFT JOIN
    PRODUCTS joining
ON
    joining.center = core.center_id
AND joining.ptype = 5
AND joining.GLOBALID = 'CREATION_'||core.GLOBALID
GROUP BY
    centerid,
    centername,
    core.price
ORDER BY
    centerid