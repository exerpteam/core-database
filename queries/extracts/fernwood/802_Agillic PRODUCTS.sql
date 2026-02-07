WITH
    params AS
    (
        SELECT
            /*+ materialize  */
            c.id AS CENTER_ID,
            CASE
                WHEN $$offset$$ = -1
                THEN 0
                ELSE datetolongtz(TO_CHAR(CURRENT_DATE- $$offset$$ , 'YYYY-MM-DD HH24:MI'),
                    c.time_zone)
            END                                                                      AS FROM_DATE,
            datetolongtz(TO_CHAR(CURRENT_DATE+1, 'YYYY-MM-DD HH24:MI'), c.time_zone) AS TO_DATE
        FROM
            centers c
        WHERE
            c.id IN ($$scope$$)
    )
SELECT
    p.CENTER || 'prod' || p.ID                         "PRODUCTS.PRODUCT_ID",
    CAST ( p.CENTER AS VARCHAR(255))                   "PRODUCTS.PRODUCT_CENTER",
    CAST ( mp.ID AS VARCHAR(255))                      "PRODUCTS.MASTER_PRODUCT_ID",
    CAST ( p.PRIMARY_PRODUCT_GROUP_ID AS VARCHAR(255)) "PRODUCTS.PRIMARY_PRODUCT_GROUP_ID",
    mp.GLOBALID                       AS                                     "PRODUCTS.GLOBAL_NAME",
    p.NAME                                   AS                                     "PRODUCTS.NAME",
    BI_DECODE_FIELD('PRODUCTS','PTYPE',p.PTYPE) AS                                  "PRODUCTS.PRODUCT_TYPE"
    ,
    p.EXTERNAL_ID                        AS "PRODUCTS.EXTERNAL_ID",
    CAST ( p.PRICE AS VARCHAR(255))      AS "PRODUCTS.SALES_PRICE",
    CAST ( p.MIN_PRICE AS VARCHAR(255))  AS "PRODUCTS.MINIMUM_PRICE",
    CAST ( p.COST_PRICE AS VARCHAR(255)) AS "PRODUCTS.COST_PRICE",
    CASE
        WHEN p.BLOCKED = 0
        THEN 'FALSE'
        WHEN p.BLOCKED = 1
        THEN 'TRUE'
    END                                      AS "PRODUCTS.BLOCKED",
    CAST(p.SALES_COMMISSION AS VARCHAR(255))  AS "PRODUCTS.SALES_COMMISSION",
    CAST(p.SALES_UNITS AS VARCHAR(255))       AS "PRODUCTS.SALES_UNITS",
    CAST(p.PERIOD_COMMISSION AS VARCHAR(255)) AS "PRODUCTS.PERIOD_COMMISSION",
    CASE
        WHEN MAX(pg.EXCLUDE_FROM_MEMBER_COUNT) =0
        AND p.PTYPE = 10
        THEN 'TRUE'
        ELSE 'FALSE'
    END                                                         AS "PRODUCTS.INCLUDED_MEMBER_COUNT",
    TO_CHAR(longtodatetz(p.LAST_MODIFIED , cen.time_zone),'dd.MM.yyyy HH24:MI:SS') AS
                                                    "PRODUCTS.LAST_UPDATED_EXERP",
    CAST(p.flat_rate_commission AS VARCHAR(255)) AS "PRODUCTS.FLAT_RATE_COMMISSION",
    prid.PRODUCT_GROUP                           AS "PRODUCTS.PRODUCT_GROUP_IDS"
FROM
    PRODUCTS p
LEFT JOIN
    MASTERPRODUCTREGISTER mp
ON
    mp.ID = mp.DEFINITION_KEY
AND p.GLOBALID = mp.GLOBALID
LEFT JOIN
    PRODUCT_AND_PRODUCT_GROUP_LINK ppgl
ON
    ppgl.PRODUCT_CENTER = p.center
AND ppgl.PRODUCT_ID = p.id
LEFT JOIN
    PRODUCT_GROUP pg
ON
    pg.ID = ppgl.PRODUCT_GROUP_ID
JOIN
    centers cen
ON
    cen.id = p.center
LEFT JOIN
    (
        SELECT
            product_center,
            product_id,
            STRING_AGG(DISTINCT CAST ( product_group_id AS text), '-') AS PRODUCT_GROUP
        FROM
            product_and_product_group_link ppgl
        GROUP BY
            product_center,
            product_id) prid
ON
    prid.product_center = p.center
AND prid.product_id = p.id
JOIN
    params
ON
    params.CENTER_ID = cen.id
WHERE
    p.PTYPE NOT IN (5,7,12)
    -- Only products updated in the last 48 hours
AND p.LAST_MODIFIED > params.FROM_DATE
GROUP BY
    p.CENTER || 'prod' || p.ID ,
    p.CENTER ,
    mp.id ,
    p.PRIMARY_PRODUCT_GROUP_ID ,
    p.NAME ,
    p.PTYPE,
    p.EXTERNAL_ID ,
    p.PRICE ,
    p.MIN_PRICE ,
    p.COST_PRICE ,
    CASE
        WHEN p.BLOCKED = 0
        THEN 'FALSE'
        WHEN p.BLOCKED = 1
        THEN 'TRUE'
    END ,
    CAST(p.SALES_COMMISSION AS VARCHAR(255)) ,
    CAST(p.SALES_UNITS AS VARCHAR(255)) ,
    CAST(p.PERIOD_COMMISSION AS VARCHAR(255)) ,
    p.LAST_MODIFIED,
    CAST(p.flat_rate_commission AS VARCHAR(255)),
    cen.time_zone,
    prid.PRODUCT_GROUP
UNION ALL
SELECT
    p.CENTER || 'prod' || p.ID                         PRODUCT_ID,
    CAST ( p.CENTER AS VARCHAR(255))                   "PRODUCTS.PRODUCT_CENTER",
    CAST ( mp.ID AS VARCHAR(255))                      "PRODUCTS.MASTER_PRODUCT_ID",
    CAST ( p.PRIMARY_PRODUCT_GROUP_ID AS VARCHAR(255)) "PRODUCTS.PRIMARY_PRODUCT_GROUP_ID",
    mp.GLOBALID                       AS                                     "PRODUCTS.GLOBAL_NAME",
    p.NAME                                   AS                                     "PRODUCTS.NAME",
    BI_DECODE_FIELD('PRODUCTS','PTYPE',p.PTYPE) AS                                  "PRODUCTS.PRODUCT_TYPE"
    ,
    p.EXTERNAL_ID                        AS "PRODUCTS.EXTERNAL_ID",
    CAST ( p.PRICE AS VARCHAR(255))      AS "PRODUCTS.SALES_PRICE",
    CAST ( p.MIN_PRICE AS VARCHAR(255))  AS "PRODUCTS.MINIMUM_PRICE",
    CAST ( p.COST_PRICE AS VARCHAR(255)) AS "PRODUCTS.COST_PRICE",
    CASE
        WHEN p.BLOCKED = 0
        THEN 'FALSE'
        WHEN p.BLOCKED = 1
        THEN 'TRUE'
    END                                      AS "PRODUCTS.BLOCKED",
    CAST(p.SALES_COMMISSION AS VARCHAR(255))                        AS "PRODUCTS.SALES_COMMISSION",
    CAST(p.SALES_UNITS AS VARCHAR(255))                                  AS "PRODUCTS.SALES_UNITS",
    CAST(p.PERIOD_COMMISSION AS VARCHAR(255))                       AS "PRODUCTS.PERIOD_COMMISSION",
    'FALSE'                                                     AS "PRODUCTS.INCLUDED_MEMBER_COUNT",
    TO_CHAR(longtodatetz(p.LAST_MODIFIED , cen.time_zone),'dd.MM.yyyy HH24:MI:SS') AS
                                                    "PRODUCTS.LAST_UPDATED_EXERP",
    CAST(p.flat_rate_commission AS VARCHAR(255)) AS "PRODUCTS.FLAT_RATE_COMMISSION",
    prid.PRODUCT_GROUP                           AS "PRODUCTS.PRODUCT_GROUP_IDS"
FROM
    PRODUCTS p
LEFT JOIN
    subscriptiontypes st
ON
    st.PRODUCTNEW_CENTER = p.center
AND st.PRODUCTNEW_ID = p.id
LEFT JOIN
    products spr
ON
    spr.center = st.center
AND spr.id = st.id
LEFT JOIN
    MASTERPRODUCTREGISTER mp
ON
    mp.ID = mp.DEFINITION_KEY
AND spr.GLOBALID = mp.GLOBALID
JOIN
    centers cen
ON
    cen.id = p.center
LEFT JOIN
    (
        SELECT
            product_center,
            product_id,
            STRING_AGG(DISTINCT CAST ( product_group_id AS text), '-') AS PRODUCT_GROUP
        FROM
            product_and_product_group_link ppgl
        GROUP BY
            product_center,
            product_id) prid
ON
    prid.product_center = p.center
AND prid.product_id = p.id
JOIN
    params
ON
    params.CENTER_ID = cen.id
WHERE
    p.PTYPE = 5
    -- Only products updated in the last 48 hours
AND p.LAST_MODIFIED > params.FROM_DATE
UNION ALL
SELECT
    p.CENTER || 'prod' || p.ID                         PRODUCT_ID,
    CAST ( p.CENTER AS VARCHAR(255))                   "PRODUCTS.PRODUCT_CENTER",
    CAST ( mp.ID AS VARCHAR(255))                      "PRODUCTS.MASTER_PRODUCT_ID",
    CAST ( p.PRIMARY_PRODUCT_GROUP_ID AS VARCHAR(255)) "PRODUCTS.PRIMARY_PRODUCT_GROUP_ID",
    mp.GLOBALID                       AS                                     "PRODUCTS.GLOBAL_NAME",
    p.NAME                                   AS                                     "PRODUCTS.NAME",
    BI_DECODE_FIELD('PRODUCTS','PTYPE',p.PTYPE) AS                                  "PRODUCTS.PRODUCT_TYPE"
    ,
    p.EXTERNAL_ID                        AS "PRODUCTS.EXTERNAL_ID",
    CAST ( p.PRICE AS VARCHAR(255))      AS "PRODUCTS.SALES_PRICE",
    CAST ( p.MIN_PRICE AS VARCHAR(255))  AS "PRODUCTS.MINIMUM_PRICE",
    CAST ( p.COST_PRICE AS VARCHAR(255)) AS "PRODUCTS.COST_PRICE",
    CASE
        WHEN p.BLOCKED = 0
        THEN 'FALSE'
        WHEN p.BLOCKED = 1
        THEN 'TRUE'
    END                                      AS "PRODUCTS.BLOCKED",
    CAST(p.SALES_COMMISSION AS VARCHAR(255))                        AS "PRODUCTS.SALES_COMMISSION",
    CAST(p.SALES_UNITS AS VARCHAR(255))                                  AS "PRODUCTS.SALES_UNITS",
    CAST(p.PERIOD_COMMISSION AS VARCHAR(255))                       AS "PRODUCTS.PERIOD_COMMISSION",
    'FALSE'                                                     AS "PRODUCTS.INCLUDED_MEMBER_COUNT",
    TO_CHAR(longtodatetz(p.LAST_MODIFIED , cen.time_zone),'dd.MM.yyyy HH24:MI:SS') AS
                                                    "PRODUCTS.LAST_UPDATED_EXERP",
    CAST(p.flat_rate_commission AS VARCHAR(255)) AS "PRODUCTS.FLAT_RATE_COMMISSION",
    prid.PRODUCT_GROUP                           AS "PRODUCTS.PRODUCT_GROUP_IDS"
FROM
    PRODUCTS p
LEFT JOIN
    subscriptiontypes st
ON
    st.FREEZEPERIODPRODUCT_CENTER = p.center
AND st.FREEZEPERIODPRODUCT_ID = p.id
LEFT JOIN
    products spr
ON
    spr.center = st.center
AND spr.id = st.id
LEFT JOIN
    MASTERPRODUCTREGISTER mp
ON
    mp.ID = mp.DEFINITION_KEY
AND spr.GLOBALID = mp.GLOBALID
JOIN
    centers cen
ON
    cen.id = p.center
LEFT JOIN
    (
        SELECT
            product_center,
            product_id,
            STRING_AGG(DISTINCT CAST ( product_group_id AS text), '-') AS PRODUCT_GROUP
        FROM
            product_and_product_group_link ppgl
        GROUP BY
            product_center,
            product_id) prid
ON
    prid.product_center = p.center
AND prid.product_id = p.id
JOIN
    params
ON
    params.CENTER_ID = cen.id
WHERE
    p.PTYPE = 7
    -- Only products updated in the last 48 hours
AND p.LAST_MODIFIED > params.FROM_DATE
UNION ALL
SELECT
    p.CENTER || 'prod' || p.ID                         PRODUCT_ID,
    CAST ( p.CENTER AS VARCHAR(255))                   "PRODUCTS.PRODUCT_CENTER",
    CAST ( mp.ID AS VARCHAR(255))                      "PRODUCTS.MASTER_PRODUCT_ID",
    CAST ( p.PRIMARY_PRODUCT_GROUP_ID AS VARCHAR(255)) "PRODUCTS.PRIMARY_PRODUCT_GROUP_ID",
    mp.GLOBALID                       AS                                     "PRODUCTS.GLOBAL_NAME",
    p.NAME                                   AS                                     "PRODUCTS.NAME",
    BI_DECODE_FIELD('PRODUCTS','PTYPE',p.PTYPE) AS                                  "PRODUCTS.PRODUCT_TYPE"
    ,
    p.EXTERNAL_ID                        AS "PRODUCTS.EXTERNAL_ID",
    CAST ( p.PRICE AS VARCHAR(255))      AS "PRODUCTS.SALES_PRICE",
    CAST ( p.MIN_PRICE AS VARCHAR(255))  AS "PRODUCTS.MINIMUM_PRICE",
    CAST ( p.COST_PRICE AS VARCHAR(255)) AS "PRODUCTS.COST_PRICE",
    CASE
        WHEN p.BLOCKED = 0
        THEN 'FALSE'
        WHEN p.BLOCKED = 1
        THEN 'TRUE'
    END                                      AS "PRODUCTS.BLOCKED",
    CAST(p.SALES_COMMISSION AS VARCHAR(255))                        AS "PRODUCTS.SALES_COMMISSION",
    CAST(p.SALES_UNITS AS VARCHAR(255))                                  AS "PRODUCTS.SALES_UNITS",
    CAST(p.PERIOD_COMMISSION AS VARCHAR(255))                       AS "PRODUCTS.PERIOD_COMMISSION",
    'FALSE'                                                     AS "PRODUCTS.INCLUDED_MEMBER_COUNT",
    TO_CHAR(longtodatetz(p.LAST_MODIFIED , cen.time_zone),'dd.MM.yyyy HH24:MI:SS') AS
                                                    "PRODUCTS.LAST_UPDATED_EXERP",
    CAST(p.flat_rate_commission AS VARCHAR(255)) AS "PRODUCTS.FLAT_RATE_COMMISSION",
    prid.PRODUCT_GROUP                           AS "PRODUCTS.PRODUCT_GROUP_IDS"
FROM
    PRODUCTS p
LEFT JOIN
    subscriptiontypes st
ON
    st.prorataproduct_center = p.center
AND st.prorataproduct_id = p.id
LEFT JOIN
    products spr
ON
    spr.center = st.center
AND spr.id = st.id
LEFT JOIN
    MASTERPRODUCTREGISTER mp
ON
    mp.ID = mp.DEFINITION_KEY
AND spr.GLOBALID = mp.GLOBALID
JOIN
    centers cen
ON
    cen.id = p.center
LEFT JOIN
    (
        SELECT
            product_center,
            product_id,
            STRING_AGG(DISTINCT CAST ( product_group_id AS text), '-') AS PRODUCT_GROUP
        FROM
            product_and_product_group_link ppgl
        GROUP BY
            product_center,
            product_id) prid
ON
    prid.product_center = p.center
AND prid.product_id = p.id
JOIN
    params
ON
    params.CENTER_ID = cen.id
WHERE
    p.PTYPE = 12
    -- Only products updated recently
AND p.LAST_MODIFIED > params.FROM_DATE