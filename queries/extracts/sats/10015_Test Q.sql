SELECT
    pp.ID                        AS "ID",
    pp.PRIVILEGE_SET             AS "PRIVILEGE_SET_ID",
    pp.price_modification_name   AS "PRICE_MOD_TYPE",
    pp.price_modification_amount AS "PRICE_MOD_VALUE",
    pp.disable_min_price         AS "DISABLE_MIN_PRICE",
    pp.purchase_right            AS "GRANT_PURCHASE",
    CASE
        WHEN ref_type = 'GLOBAL_PRODUCT'
        THEN 'MASTER_PRODUCT'
        ELSE ref_type
    END AS "REF_TYPE",
    CASE
        WHEN ref_type = 'GLOBAL_PRODUCT'
        THEN pp.mprid
        ELSE ref_id
    END AS "REF_ID",
    CASE
        WHEN ref_type = 'GLOBAL_PRODUCT'
        THEN
            CASE
                WHEN pp.ref_globalid LIKE 'CREATION_%'
                THEN 'JOINING_FEE'
                WHEN pp.ref_globalid LIKE 'PRORATA_%'
                THEN 'SUBS_PRORATA'
                WHEN pp.ref_globalid LIKE 'FREEZE_%'
                THEN 'FREEZE_PERIOD'
                ELSE BI_DECODE_FIELD('PRODUCTS','PTYPE',mpr_cached_producttype)
            END
    END AS "PRODUCT_TYPE",
    CASE
        WHEN pp.valid_for LIKE 'ASS[%'
        THEN 'ABSOLUTE'
        WHEN pp.valid_for = 'LSS'
        THEN 'LOCAL'
        WHEN pp.valid_for LIKE 'RSS[%'
        THEN 'RELATIVE'
        WHEN pp.valid_for LIKE 'AG[%'
        THEN 'FOLLOW_ACCESS_GROUP'
    END AS "APPLY_TYPE",
    CASE
        WHEN pp.valid_for LIKE 'ASS[%'
        THEN
            CASE
                WHEN SUBSTR(pp.valid_for, 5,1) IN ('G',
                                                   'T')
                THEN 'GLOBAL'
                WHEN SUBSTR(pp.valid_for, 5,1) = 'A'
                THEN 'AREA'
                WHEN SUBSTR(pp.valid_for, 5,1) = 'C'
                THEN 'CENTER'
            END
        WHEN pp.valid_for LIKE 'AG[%'
        THEN 'ACCESS_GROUP'
        WHEN pp.valid_for LIKE 'RSS[%'
        THEN 'AREA'
    END AS "APPLY_REF_TYPE",
    CAST(
        CASE
            WHEN pp.valid_for LIKE 'ASS[%'
                AND NOT(SUBSTR(pp.valid_for, 5,1) IN ('G',
                                                      'T'))
            THEN SUBSTR(pp.valid_for, 6,INSTR(pp.valid_for, ']', 1)-6)
            WHEN (pp.valid_for LIKE 'AG[%')
            THEN SUBSTR(pp.valid_for, 3,INSTR(pp.valid_for, ']', 1)-3)
            WHEN pp.valid_for LIKE 'RSS[%'
            THEN SUBSTR(pp.valid_for, 5,INSTR(pp.valid_for, ',', 1)-5)
        END AS INTEGER) AS "APPLY_REF_ID",
    CAST(
        CASE
            WHEN pp.valid_for LIKE 'RSS[%'
            THEN SUBSTR(pp.valid_for,-2,1)
        END AS INTEGER) AS "RELATIVE_EXPANSION"
FROM
    (
        SELECT DISTINCT
            pp.*,
            mpr.id                 AS mprid,
            mpr.cached_producttype AS mpr_cached_producttype
        FROM
            PRODUCT_PRIVILEGES pp
        LEFT JOIN
            masterproductregister mpr
        ON
            mpr.globalid = pp.ref_globalid
            AND pp.ref_type = 'GLOBAL_PRODUCT'
            AND mpr.id = mpr.definition_key
        WHERE
            pp.VALID_TO IS NULL
            AND (
                SUBSTR(pp.ref_globalid,0,9) != 'CREATION_'
                AND SUBSTR(pp.ref_globalid,0,8) != 'PRORATA_'
                AND SUBSTR(pp.ref_globalid,0,7) != 'FREEZE_'
                OR pp.ref_globalid IS NULL)
        UNION ALL
        SELECT DISTINCT
            pp.*,
            mpr.id                 AS mprid,
            mpr.cached_producttype AS mpr_cached_producttype
        FROM
            PRODUCT_PRIVILEGES pp
        JOIN
            PRODUCTS p
        ON
            p.GLOBALID = pp.ref_globalid
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
            MASTERPRODUCTREGISTER mpr
        ON
            mpr.ID = mpr.DEFINITION_KEY
            AND spr.GLOBALID = mpr.GLOBALID
        WHERE
            pp.VALID_TO IS NULL
            AND SUBSTR(pp.ref_globalid,0,9) = 'CREATION_'
        UNION ALL
        SELECT DISTINCT
            pp.*,
            mpr.id                 AS mprid,
            mpr.cached_producttype AS mpr_cached_producttype
        FROM
            PRODUCT_PRIVILEGES pp
        JOIN
            PRODUCTS p
        ON
            p.GLOBALID = pp.ref_globalid
        JOIN
            subscriptiontypes st
        ON
            st.productnew_center = p.center
            AND st.productnew_id = p.id
        JOIN
            products spr
        ON
            spr.center = st.center
            AND spr.id = st.id
        JOIN
            MASTERPRODUCTREGISTER mpr
        ON
            mpr.ID = mpr.DEFINITION_KEY
            AND spr.GLOBALID = mpr.GLOBALID
        WHERE
            pp.VALID_TO IS NULL
            AND SUBSTR(pp.ref_globalid,0,8) = 'PRORATA_'
        UNION ALL
        SELECT DISTINCT
            pp.*,
            mpr.id                 AS mprid,
            mpr.cached_producttype AS mpr_cached_producttype
        FROM
            PRODUCT_PRIVILEGES pp
        JOIN
            PRODUCTS p
        ON
            p.GLOBALID = pp.ref_globalid
        JOIN
            subscriptiontypes st
        ON
            st.freezeperiodproduct_center = p.center
            AND st.freezeperiodproduct_id = p.id
        JOIN
            products spr
        ON
            spr.center = st.center
            AND spr.id = st.id
        JOIN
            MASTERPRODUCTREGISTER mpr
        ON
            mpr.ID = mpr.DEFINITION_KEY
            AND spr.GLOBALID = mpr.GLOBALID
        WHERE
            pp.VALID_TO IS NULL
            AND SUBSTR(pp.ref_globalid,0,7) = 'FREEZE_') pp