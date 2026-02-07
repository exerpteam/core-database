SELECT
    p.CENTER || 'prod' || p.ID "ID",
    p.CENTER                   "CENTER_ID",
    mp.ID                      "MASTER_PRODUCT_ID",
    p.PRIMARY_PRODUCT_GROUP_ID "PRODUCT_GROUP_ID",
    p.NAME                                      AS                  "NAME",
	CASE 
        WHEN p.PTYPE = 1 THEN 'RETAIL'
        WHEN p.PTYPE = 2 THEN 'SERVICE'
        WHEN p.PTYPE = 4 THEN 'CLIPCARD'
        WHEN p.PTYPE = 5 THEN 'JOINING_FEE'
        WHEN p.PTYPE = 6 THEN 'TRANSFER_FEE'
        WHEN p.PTYPE = 7 THEN 'FREEZE_PERIOD'
        WHEN p.PTYPE = 8 THEN 'GIFTCARD'
        WHEN p.PTYPE = 9 THEN 'FREE_GIFTCARD'
        WHEN p.PTYPE = 10 THEN 'SUBS_PERIOD'
        WHEN p.PTYPE = 12 THEN 'SUBS_PRORATA'
        WHEN p.PTYPE = 13 THEN 'ADDON'
        WHEN p.PTYPE = 14 THEN 'ACCESS'
        ELSE 'UNKNOWN'
	END AS "TYPE", 
    p.EXTERNAL_ID                               AS                  "EXTERNAL_ID",
    p.PRICE                                                         "SALES_PRICE",
    p.MIN_PRICE                                                     "MINIMUM_PRICE",
    p.COST_PRICE                    AS                                                 "COST_PRICE",
    CAST(CAST (p.BLOCKED AS INT) AS SMALLINT) AS                                       "BLOCKED",
    p.SALES_COMMISSION                        AS                                       "SALES_COMMISSION"
    ,
    p.SALES_UNITS       AS "SALES_UNITS",
    p.PERIOD_COMMISSION AS "PERIOD_COMMISSION",
    CASE
        WHEN p.PTYPE = 10
        AND NOT EXISTS
            (
                SELECT
                    1
                FROM
                    PRODUCT_AND_PRODUCT_GROUP_LINK ppgl
                JOIN
                    PRODUCT_GROUP pg
                ON
                    pg.ID = ppgl.PRODUCT_GROUP_ID
                WHERE
                    pg.EXCLUDE_FROM_MEMBER_COUNT = 1
                AND ppgl.PRODUCT_CENTER = p.center
                AND ppgl.PRODUCT_ID = p.id )
        THEN 1
        ELSE 0
    END AS                    "INCLUDED_MEMBER_COUNT",
    p.LAST_MODIFIED           "ETS",
    p.flat_rate_commission AS "FLAT_RATE_COMMISSION",
    CASE
        WHEN st.ST_TYPE = 0
        THEN 'CASH'
        WHEN st.ST_TYPE = 1
        THEN 'EFT'
        WHEN st.ST_TYPE = 2
        THEN 'CLIPCARD'
        WHEN st.ST_TYPE = 3
        THEN 'COURSE'
    END           AS "SUBSCRIPTION_TYPE",
    CASE
        WHEN st.PERIODUNIT = 0
        THEN 'WEEK'
        WHEN st.PERIODUNIT = 1
        THEN 'DAY'
        WHEN st.PERIODUNIT = 2
        THEN 'MONTH'
        WHEN st.PERIODUNIT = 3
        THEN 'YEAR'
    END                                                       AS "PERIOD_UNIT",
    st.PERIODCOUNT                                            AS "PERIOD_COUNT",
    COALESCE(st.BINDINGPERIODCOUNT, aop.binding_period_count) AS "BINDING_PERIOD_COUNT",
    st.AUTO_STOP_ON_BINDING_END_DATE                          AS "STOP_ON_BINDING_END_DATE" ,
	COALESCE(p.WEBNAME, mp.WEBNAME)                           AS "WEBNAME",
	p.COMMISSIONABLE										  AS "COMMISSIONABLE"
FROM
    PRODUCTS p
LEFT JOIN
    MASTERPRODUCTREGISTER mp
ON
    mp.ID = mp.DEFINITION_KEY
AND p.GLOBALID = mp.GLOBALID
LEFT JOIN
    SUBSCRIPTIONTYPES st
ON
    p.PTYPE = 10 -- SUBSCRIPTIONS
AND st.CENTER = p.CENTER
AND st.ID = p.ID
LEFT JOIN
    add_on_product_definition aop
ON
    aop.id = mp.id
WHERE
    p.PTYPE NOT IN (5,6,7,12)

UNION ALL
SELECT
    p.CENTER || 'prod' || p.ID "ID",
    p.CENTER                   "CENTER_ID",
    mp.ID                      "MASTER_PRODUCT_ID",
    p.PRIMARY_PRODUCT_GROUP_ID "PRODUCT_GROUP_ID",
    p.NAME,
	CASE 
        WHEN p.PTYPE = 1 THEN 'RETAIL'
        WHEN p.PTYPE = 2 THEN 'SERVICE'
        WHEN p.PTYPE = 4 THEN 'CLIPCARD'
        WHEN p.PTYPE = 5 THEN 'JOINING_FEE'
        WHEN p.PTYPE = 6 THEN 'TRANSFER_FEE'
        WHEN p.PTYPE = 7 THEN 'FREEZE_PERIOD'
        WHEN p.PTYPE = 8 THEN 'GIFTCARD'
        WHEN p.PTYPE = 9 THEN 'FREE_GIFTCARD'
        WHEN p.PTYPE = 10 THEN 'SUBS_PERIOD'
        WHEN p.PTYPE = 12 THEN 'SUBS_PRORATA'
        WHEN p.PTYPE = 13 THEN 'ADDON'
        WHEN p.PTYPE = 14 THEN 'ACCESS'
        ELSE 'UNKNOWN'
	END AS "TYPE", 
    spr.EXTERNAL_ID,
    p.PRICE     SALES_PRICE,
    p.MIN_PRICE MINIMUM_PRICE,
    p.COST_PRICE,
    CAST(CAST (p.BLOCKED AS INT) AS SMALLINT) AS BLOCKED,
    p.SALES_COMMISSION                        AS SALES_COMMISSION,
    p.SALES_UNITS                             AS SALES_UNITS,
    p.PERIOD_COMMISSION                       AS PERIOD_COMMISSION,
    0                                         AS "INCLUDED_MEMBER_COUNT",
    p.LAST_MODIFIED                              ETS,
    p.FLAT_RATE_COMMISSION                    AS "FLAT_RATE_COMMISSION",
    NULL                                      AS "SUBSCRIPTION_TYPE",
    NULL                                      AS "PERIOD_UNIT",
    NULL                                      AS "PERIOD_COUNT",
    NULL                                      AS "BINDING_PERIOD_COUNT",
    NULL                                      AS "STOP_ON_BINDING_END_DATE",
    p.WEBNAME                                 AS "WEBNAME",
	p.COMMISSIONABLE						  AS "COMMISSIONABLE"	
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
WHERE
    p.PTYPE = 5 -- JOINING_FEE

UNION ALL
SELECT
    p.CENTER || 'prod' || p.ID "ID",
    p.CENTER                   "CENTER_ID",
    mp.ID                      "MASTER_PRODUCT_ID",
    p.PRIMARY_PRODUCT_GROUP_ID "PRODUCT_GROUP_ID",
    p.NAME,
	CASE 
        WHEN p.PTYPE = 1 THEN 'RETAIL'
        WHEN p.PTYPE = 2 THEN 'SERVICE'
        WHEN p.PTYPE = 4 THEN 'CLIPCARD'
        WHEN p.PTYPE = 5 THEN 'JOINING_FEE'
        WHEN p.PTYPE = 6 THEN 'TRANSFER_FEE'
        WHEN p.PTYPE = 7 THEN 'FREEZE_PERIOD'
        WHEN p.PTYPE = 8 THEN 'GIFTCARD'
        WHEN p.PTYPE = 9 THEN 'FREE_GIFTCARD'
        WHEN p.PTYPE = 10 THEN 'SUBS_PERIOD'
        WHEN p.PTYPE = 12 THEN 'SUBS_PRORATA'
        WHEN p.PTYPE = 13 THEN 'ADDON'
        WHEN p.PTYPE = 14 THEN 'ACCESS'
        ELSE 'UNKNOWN'
	END AS "TYPE", 
    spr.EXTERNAL_ID,
    p.PRICE         "SALES_PRICE",
    p.MIN_PRICE     "MINIMUM_PRICE",
    p.COST_PRICE                              AS "COST_PRICE",
    CAST(CAST (p.BLOCKED AS INT) AS SMALLINT) AS "BLOCKED",
    p.SALES_COMMISSION                        AS "SALES_COMMISSION",
    p.SALES_UNITS                             AS "SALES_UNITS",
    p.PERIOD_COMMISSION                       AS "PERIOD_COMMISSION",
    0                                         AS "INCLUDED_MEMBER_COUNT",
    p.LAST_MODIFIED                              "ETS",
    p.FLAT_RATE_COMMISSION AS                    "FLAT_RATE_COMMISSION",
    NULL                   AS                    "SUBSCRIPTION_TYPE",
    NULL                   AS                    "PERIOD_UNIT",
    NULL                   AS                    "PERIOD_COUNT",
    NULL                   AS                    "BINDING_PERIOD_COUNT",
    NULL                   AS                    "STOP_ON_BINDING_END_DATE",
    p.WEBNAME              AS                    "WEBNAME",
	p.COMMISSIONABLE	   AS                    "COMMISSIONABLE"	
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
WHERE
    p.PTYPE = 7 -- FREEZE_PERIOD

UNION ALL
SELECT
    p.CENTER || 'prod' || p.ID "ID",
    p.CENTER                   "CENTER_ID",
    mp.ID                      "MASTER_PRODUCT_ID",
    p.PRIMARY_PRODUCT_GROUP_ID "PRODUCT_GROUP_ID",
    p.NAME,
	CASE 
        WHEN p.PTYPE = 1 THEN 'RETAIL'
        WHEN p.PTYPE = 2 THEN 'SERVICE'
        WHEN p.PTYPE = 4 THEN 'CLIPCARD'
        WHEN p.PTYPE = 5 THEN 'JOINING_FEE'
        WHEN p.PTYPE = 6 THEN 'TRANSFER_FEE'
        WHEN p.PTYPE = 7 THEN 'FREEZE_PERIOD'
        WHEN p.PTYPE = 8 THEN 'GIFTCARD'
        WHEN p.PTYPE = 9 THEN 'FREE_GIFTCARD'
        WHEN p.PTYPE = 10 THEN 'SUBS_PERIOD'
        WHEN p.PTYPE = 12 THEN 'SUBS_PRORATA'
        WHEN p.PTYPE = 13 THEN 'ADDON'
        WHEN p.PTYPE = 14 THEN 'ACCESS'
        ELSE 'UNKNOWN'
	END AS "TYPE", 
    spr.EXTERNAL_ID,
    p.PRICE     SALES_PRICE,
    p.MIN_PRICE MINIMUM_PRICE,
    p.COST_PRICE,
    CAST(CAST (p.BLOCKED AS INT) AS SMALLINT) AS BLOCKED,
    p.SALES_COMMISSION                        AS SALES_COMMISSION,
    p.SALES_UNITS                             AS SALES_UNITS,
    p.PERIOD_COMMISSION                       AS PERIOD_COMMISSION,
    0                                         AS "INCLUDED_MEMBER_COUNT",
    p.LAST_MODIFIED                              ETS,
    p.FLAT_RATE_COMMISSION                    AS "FLAT_RATE_COMMISSION",
    NULL                                      AS "SUBSCRIPTION_TYPE",
    NULL                                      AS "PERIOD_UNIT",
    NULL                                      AS "PERIOD_COUNT",
    NULL                                      AS "BINDING_PERIOD_COUNT",
    NULL                                      AS "STOP_ON_BINDING_END_DATE",
    p.WEBNAME                                 AS "WEBNAME",
	p.COMMISSIONABLE						  AS "COMMISSIONABLE"	
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
WHERE
    p.PTYPE = 12 -- PRORATA_PERIOD

UNION ALL
SELECT
    p.CENTER || 'prod' || p.ID "ID",
    p.CENTER                   "CENTER_ID",
    mp.ID                      "MASTER_PRODUCT_ID",
    p.PRIMARY_PRODUCT_GROUP_ID "PRODUCT_GROUP_ID",
    p.NAME,
	CASE 
        WHEN p.PTYPE = 1 THEN 'RETAIL'
        WHEN p.PTYPE = 2 THEN 'SERVICE'
        WHEN p.PTYPE = 4 THEN 'CLIPCARD'
        WHEN p.PTYPE = 5 THEN 'JOINING_FEE'
        WHEN p.PTYPE = 6 THEN 'TRANSFER_FEE'
        WHEN p.PTYPE = 7 THEN 'FREEZE_PERIOD'
        WHEN p.PTYPE = 8 THEN 'GIFTCARD'
        WHEN p.PTYPE = 9 THEN 'FREE_GIFTCARD'
        WHEN p.PTYPE = 10 THEN 'SUBS_PERIOD'
        WHEN p.PTYPE = 12 THEN 'SUBS_PRORATA'
        WHEN p.PTYPE = 13 THEN 'ADDON'
        WHEN p.PTYPE = 14 THEN 'ACCESS'
        ELSE 'UNKNOWN'
	END AS "TYPE", 
    spr.EXTERNAL_ID,
    p.PRICE     SALES_PRICE,
    p.MIN_PRICE MINIMUM_PRICE,
    p.COST_PRICE,
    CAST(CAST (p.BLOCKED AS INT) AS SMALLINT) AS BLOCKED,
    p.SALES_COMMISSION                        AS SALES_COMMISSION,
    p.SALES_UNITS                             AS SALES_UNITS,
    p.PERIOD_COMMISSION                       AS PERIOD_COMMISSION,
    0                                         AS "INCLUDED_MEMBER_COUNT",
    p.LAST_MODIFIED                              ETS,
    p.FLAT_RATE_COMMISSION                    AS "FLAT_RATE_COMMISSION",
    NULL                                      AS "SUBSCRIPTION_TYPE",
    NULL                                      AS "PERIOD_UNIT",
    NULL                                      AS "PERIOD_COUNT",
    NULL                                      AS "BINDING_PERIOD_COUNT",
    NULL                                      AS "STOP_ON_BINDING_END_DATE",
    p.WEBNAME                                 AS "WEBNAME",
	p.COMMISSIONABLE						  AS "COMMISSIONABLE"	
FROM
    PRODUCTS p
LEFT JOIN
    subscriptiontypes st
ON
    st.TRANSFERPRODUCT_CENTER = p.center
    AND st.TRANSFERPRODUCT_ID = p.id
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
WHERE
    p.PTYPE = 6 -- TRANSFER_FEE
