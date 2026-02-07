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
				ELSE
				CASE 
					WHEN mpr_cached_producttype = 1 THEN 'RETAIL'
					WHEN mpr_cached_producttype = 2 THEN 'SERVICE'
					WHEN mpr_cached_producttype = 4 THEN 'CLIPCARD'
					WHEN mpr_cached_producttype = 5 THEN 'JOINING_FEE'
					WHEN mpr_cached_producttype = 6 THEN 'TRANSFER_FEE'
					WHEN mpr_cached_producttype = 7 THEN 'FREEZE_PERIOD'
					WHEN mpr_cached_producttype = 8 THEN 'GIFTCARD'
					WHEN mpr_cached_producttype = 9 THEN 'FREE_GIFTCARD'
					WHEN mpr_cached_producttype = 10 THEN 'SUBS_PERIOD'
					WHEN mpr_cached_producttype = 12 THEN 'SUBS_PRORATA'
					WHEN mpr_cached_producttype = 13 THEN 'ADDON'
					WHEN mpr_cached_producttype = 14 THEN 'ACCESS'
				ELSE 'UNKNOWN'
				END
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
                WHEN substring(pp.valid_for, 5,1) IN ('G',
                                                      'T')
                THEN 'GLOBAL'
                WHEN substring(pp.valid_for, 5,1) = 'A'
                THEN 'AREA'
                WHEN substring(pp.valid_for, 5,1) = 'C'
                THEN 'CENTER'
            END
        WHEN pp.valid_for LIKE 'AG[%'
        THEN 'ACCESS_GROUP'
        WHEN pp.valid_for LIKE 'RSS[%'
        THEN 'AREA'
    END AS "APPLY_REF_TYPE",
    cast(CASE
        WHEN (pp.valid_for LIKE 'ASS[%'
                OR pp.valid_for LIKE 'AG[%')
            AND NOT(substring(pp.valid_for, 5,1) IN ('G',
                                                     'T'))
        THEN trim(both 'ARSS[]GTC' FROM pp.valid_for)
        WHEN pp.valid_for LIKE 'RSS[%'
        THEN substring(pp.valid_for, 5,position(',' IN pp.valid_for)-5)
    END as INTEGER) AS "APPLY_REF_ID",
    cast(CASE
        WHEN pp.valid_for LIKE 'RSS[%'
        THEN trim(trailing ']' FROM substring(pp.valid_for FROM position(',' IN pp.valid_for) +1 ))
    END as INTEGER) AS "RELATIVE_EXPANSION"
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
        left JOIN
            PRODUCTS p
        ON
            p.GLOBALID = pp.ref_globalid
        left JOIN
            subscriptiontypes st1
        ON
            st1.productnew_center = p.center
            AND st1.productnew_id = p.id
            AND LEFT(pp.ref_globalid,9) = 'CREATION_'
        left JOIN
            subscriptiontypes st2
        ON
            st2.prorataproduct_center = p.center
            AND st2.prorataproduct_id = p.id
            AND LEFT(pp.ref_globalid,8) = 'PRORATA_'
        left JOIN
            subscriptiontypes st3
        ON
            st3.freezeperiodproduct_center = p.center
            AND st3.freezeperiodproduct_id = p.id
            AND LEFT(pp.ref_globalid,7) = 'FREEZE_'
        WHERE
            pp.VALID_TO IS NULL
            AND (
                st1.id is null 
                and st2.id is null
                and st3.id is null
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
            AND LEFT(pp.ref_globalid,9) = 'CREATION_'
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
            AND LEFT(pp.ref_globalid,8) = 'PRORATA_'
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
            AND LEFT(pp.ref_globalid,7) = 'FREEZE_') pp