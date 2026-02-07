WITH
    any_club_in_scope AS
    (
        SELECT id 
          FROM centers 
         WHERE id IN ($$scope$$)
           AND rownum = 1
    )
    , params AS
    (
        SELECT
            /*+ materialize  */
            datetolongC(TO_CHAR(TRUNC(SYSDATE)-5, 'YYYY-MM-DD HH24:MI'), any_club_in_scope.id) AS FROMDATE,
            datetolongC(TO_CHAR(TRUNC(SYSDATE+1), 'YYYY-MM-DD HH24:MI'), any_club_in_scope.id) AS TODATE
        FROM
            dual
        CROSS JOIN any_club_in_scope
    )
SELECT
    p.PRODUCT_ID
  , p.PRODUCT_CENTER
  , p.MASTER_PRODUCT_ID
  , p.NAME
  , p.PRODUCT_TYPE
  , p.EXTERNAL_ID
  , p.SALES_PRICE
  , p.MINIMUM_PRICE
  , p.COST_PRICE
  , p.PRODUCT_GROUP_ID
  , p.BLOCKED
  , p.ETS
FROM
   (
SELECT
    p.CENTER || 'prod' || p.ID                         "PRODUCT_ID",
    CAST ( p.CENTER AS VARCHAR(255))                   "PRODUCT_CENTER",
    CAST ( mp.ID AS VARCHAR(255))                      "MASTER_PRODUCT_ID",
    CAST ( p.PRIMARY_PRODUCT_GROUP_ID AS VARCHAR(255)) "PRODUCT_GROUP_ID",
    p.NAME                                      AS                                          "NAME",
    BI_DECODE_FIELD('PRODUCTS','PTYPE',p.PTYPE) AS                                          "PRODUCT_TYPE",
    p.EXTERNAL_ID                               AS                                          "EXTERNAL_ID",
    p.PRICE                                                                                 "SALES_PRICE",
    p.MIN_PRICE                                                                             "MINIMUM_PRICE",
    p.COST_PRICE AS                                                                         "COST_PRICE",
    CASE
        WHEN p.BLOCKED = 0
        THEN 'FALSE'
        WHEN p.BLOCKED = 1
        THEN 'TRUE'
    END                 AS "BLOCKED",
    p.SALES_COMMISSION  AS "SALES_COMMISSION",
    p.SALES_UNITS       AS "SALES_UNITS",
    p.PERIOD_COMMISSION AS "PERIOD_COMMISSION",
    CASE
        WHEN MAX(pg.EXCLUDE_FROM_MEMBER_COUNT) =0
            AND p.PTYPE = 10
        THEN 'TRUE'
        ELSE 'FALSE'
    END      AS     "INCLUDED_MEMBER_COUNT",
    p.center AS     "CENTER_ID",
    p.LAST_MODIFIED "ETS"
FROM
    PRODUCTS p
JOIN
    MASTERPRODUCTREGISTER mp
ON
    mp.ID = mp.DEFINITION_KEY
    AND p.GLOBALID = mp.GLOBALID
JOIN
    PRODUCT_AND_PRODUCT_GROUP_LINK ppgl
ON
    ppgl.PRODUCT_CENTER = p.center
    AND ppgl.PRODUCT_ID = p.id
JOIN
    PRODUCT_GROUP pg
ON
    pg.ID = ppgl.PRODUCT_GROUP_ID
WHERE
    p.PTYPE NOT IN (5,7,12)
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
    p.SALES_COMMISSION ,
    p.SALES_UNITS ,
    p.PERIOD_COMMISSION ,
    p.LAST_MODIFIED
UNION ALL
SELECT
    p.CENTER || 'prod' || p.ID PRODUCT_ID,
    CAST ( p.CENTER AS VARCHAR(255))                   "PRODUCT_CENTER",
    CAST ( mp.ID AS VARCHAR(255))                      "MASTER_PRODUCT_ID",
    CAST ( p.PRIMARY_PRODUCT_GROUP_ID AS VARCHAR(255)) "PRODUCT_GROUP_ID",
    p.NAME,
    BI_DECODE_FIELD('PRODUCTS','PTYPE',p.PTYPE) AS product_type,
    spr.EXTERNAL_ID,
    p.PRICE     SALES_PRICE,
    p.MIN_PRICE MINIMUM_PRICE,
    p.COST_PRICE,
    CASE
        WHEN p.BLOCKED = 0
        THEN 'FALSE'
        WHEN p.BLOCKED = 1
        THEN 'TRUE'
    END                 AS BLOCKED,
    p.SALES_COMMISSION  AS SALES_COMMISSION,
    p.SALES_UNITS       AS SALES_UNITS,
    p.PERIOD_COMMISSION AS PERIOD_COMMISSION,
    'FALSE'             AS "INCLUDED_MEMBER_COUNT",
    p.center            AS "CENTER_ID",
    p.LAST_MODIFIED        ETS
FROM
    PRODUCTS p
JOIN
    subscriptiontypes st
ON
    st.PRODUCTNEW_CENTER = p.center
    AND st.PRODUCTNEW_ID = p.id
JOIN
    products spr
ON
    spr.center = st.center
    AND spr.id = st.id
JOIN
    MASTERPRODUCTREGISTER mp
ON
    mp.ID = mp.DEFINITION_KEY
    AND spr.GLOBALID = mp.GLOBALID
WHERE
    p.PTYPE = 5
UNION ALL
SELECT
    p.CENTER || 'prod' || p.ID PRODUCT_ID,
    CAST ( p.CENTER AS VARCHAR(255))                   "PRODUCT_CENTER",
    CAST ( mp.ID AS VARCHAR(255))                      "MASTER_PRODUCT_ID",
    CAST ( p.PRIMARY_PRODUCT_GROUP_ID AS VARCHAR(255)) "PRODUCT_GROUP_ID",
    p.NAME,
    BI_DECODE_FIELD('PRODUCTS','PTYPE',p.PTYPE) AS product_type,
    spr.EXTERNAL_ID,
    p.PRICE     SALES_PRICE,
    p.MIN_PRICE MINIMUM_PRICE,
    p.COST_PRICE,
    CASE
        WHEN p.BLOCKED = 0
        THEN 'FALSE'
        WHEN p.BLOCKED = 1
        THEN 'TRUE'
    END                 AS BLOCKED,
    p.SALES_COMMISSION  AS SALES_COMMISSION,
    p.SALES_UNITS       AS SALES_UNITS,
    p.PERIOD_COMMISSION AS PERIOD_COMMISSION,
    'FALSE'             AS "INCLUDED_MEMBER_COUNT",
    p.center            AS "CENTER_ID",
    p.LAST_MODIFIED        ETS
FROM
    PRODUCTS p
JOIN
    subscriptiontypes st
ON
    st.FREEZEPERIODPRODUCT_CENTER = p.center
    AND st.FREEZEPERIODPRODUCT_ID = p.id
JOIN
    products spr
ON
    spr.center = st.center
    AND spr.id = st.id
JOIN
    MASTERPRODUCTREGISTER mp
ON
    mp.ID = mp.DEFINITION_KEY
    AND spr.GLOBALID = mp.GLOBALID
WHERE
    p.PTYPE = 7
UNION ALL
SELECT
    p.CENTER || 'prod' || p.ID PRODUCT_ID,
    CAST ( p.CENTER AS VARCHAR(255))                   "PRODUCT_CENTER",
    CAST ( mp.ID AS VARCHAR(255))                      "MASTER_PRODUCT_ID",
    CAST ( p.PRIMARY_PRODUCT_GROUP_ID AS VARCHAR(255)) "PRODUCT_GROUP_ID",
    p.NAME,
    BI_DECODE_FIELD('PRODUCTS','PTYPE',p.PTYPE) AS product_type,
    spr.EXTERNAL_ID,
    p.PRICE     SALES_PRICE,
    p.MIN_PRICE MINIMUM_PRICE,
    p.COST_PRICE,
    CASE
        WHEN p.BLOCKED = 0
        THEN 'FALSE'
        WHEN p.BLOCKED = 1
        THEN 'TRUE'
    END                 AS BLOCKED,
    p.SALES_COMMISSION  AS SALES_COMMISSION,
    p.SALES_UNITS       AS SALES_UNITS,
    p.PERIOD_COMMISSION AS PERIOD_COMMISSION,
    'FALSE'             AS "INCLUDED_MEMBER_COUNT",
    p.center            AS "CENTER_ID",
    p.LAST_MODIFIED        ETS
FROM
    PRODUCTS p
JOIN
    subscriptiontypes st
ON
    st.prorataproduct_center = p.center
    AND st.prorataproduct_id = p.id
JOIN
    products spr
ON
    spr.center = st.center
    AND spr.id = st.id
JOIN
    MASTERPRODUCTREGISTER mp
ON
    mp.ID = mp.DEFINITION_KEY
    AND spr.GLOBALID = mp.GLOBALID
WHERE
    p.PTYPE = 12) p
CROSS JOIN
    PARAMS
WHERE
    p.PRODUCT_CENTER in ($$scope$$)
    AND p.ETS >= PARAMS.FROMDATE
    AND p.ETS < PARAMS.TODATE