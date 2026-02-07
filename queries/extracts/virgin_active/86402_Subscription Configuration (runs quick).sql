SELECT *
FROM (
    SELECT
        mpr.ID AS "Master Product ID",
        prod.CENTER,
        c.NAME AS "center name",
        prod.GLOBALID AS "Global Name",
        prod.NAME AS "Product Name",
        pac.NAME AS "Account Configuration",
        sales_acc.EXTERNAL_ID AS "Sales Account",
        r.ROLENAME AS "Required Role",
        pjf.NEEDS_PRIVILEGE AS "Purchase Require Privilege",
        mpr.CACHED_PRODUCTPRICE AS "Top Level Price",
        prod.PRICE AS "Club Price",
        st.ROUNDUP_END_UNIT,
        st.RANK AS "Rank",
        CASE st.ST_TYPE
            WHEN 0 THEN 'CASH'
            WHEN 1 THEN 'EFT'
            ELSE 'UNDEFINED'
        END AS "Deduction",
        CASE st.PERIODUNIT
            WHEN 0 THEN 'WEEK'
            WHEN 1 THEN 'DAY'
            WHEN 2 THEN 'MONTH'
            WHEN 3 THEN 'YEAR'
            WHEN 4 THEN 'HOUR'
            WHEN 5 THEN 'MINUTE'
            WHEN 6 THEN 'SECOND'
            ELSE 'UNDEFINED'
        END AS "Period Unit",
        st.EXTEND_BINDING_BY_PRORATA AS "Ext. bind By prorata",
        st.IS_ADDON_SUBSCRIPTION AS "Requires Main Subscription",
        mpr.USE_CONTRACT_TEMPLATE AS "Use Contract Template",
        FIRST_VALUE(t.description)
            OVER (PARTITION BY mpr.DEFINITION_KEY ORDER BY mpr.SCOPE_TYPE DESC) AS test,
        st.RENEW_WINDOW AS "Renew Period",
        st.PERIODCOUNT AS "Period Count",
        pg.NAME AS "sub primary Product Group",
        pgAll.NAME AS "all sub groups",
        pgProRataPrimary.NAME AS "primary pro rata group",
        pgAllProRata.NAME AS "all pro rata groups",
        pgCreationPrimary.NAME AS "primary cretaion group",
        pgAllCreation.NAME AS "all creation groups",
        st.BINDINGPERIODCOUNT AS "Binding Period",
        st.PRORATAPERIODCOUNT AS "Prorata p.",
        st.INITIALPERIODCOUNT AS "Initial p.",
        fp.PRICE AS "Price During Freeze",
        CASE
            WHEN st.FREEZELIMIT IS NULL THEN 0
            ELSE 1
        END AS "can be frozen",
        CASE
            WHEN st.FREEZELIMIT IS NOT NULL THEN
                CAST((xpath('FREEZELIMIT/FREEZEAPPLYPERIOD/FREEZEDURATION/@LENGTH',
                    xmlparse(document convert_from(st.FREEZELIMIT,'UTF8'))))[1] AS VARCHAR)
                || ' ' ||
                CAST((xpath('FREEZELIMIT/FREEZEAPPLYPERIOD/FREEZEDURATION/@UNIT',
                    xmlparse(document convert_from(st.FREEZELIMIT,'UTF8'))))[1] AS VARCHAR)
            ELSE NULL
        END AS "Within a period of",
        CASE
            WHEN st.FREEZELIMIT IS NOT NULL THEN
                CAST((xpath('FREEZELIMIT/@MINDURATION',
                    xmlparse(document convert_from(st.FREEZELIMIT,'UTF8'))))[1] AS VARCHAR)
            ELSE NULL
        END AS "Min duration",
        CASE
            WHEN st.FREEZELIMIT IS NOT NULL THEN
                CAST((xpath('FREEZELIMIT/@MINDURATION_UNIT',
                    xmlparse(document convert_from(st.FREEZELIMIT,'UTF8'))))[1] AS VARCHAR)
            ELSE NULL
        END AS "Min duration Unit",
        CASE
            WHEN st.FREEZELIMIT IS NOT NULL THEN
                CAST((xpath('FREEZELIMIT/@MAXDURATION',
                    xmlparse(document convert_from(st.FREEZELIMIT,'UTF8'))))[1] AS VARCHAR)
            ELSE NULL
        END AS "Max duration",
        CASE
            WHEN st.FREEZELIMIT IS NOT NULL THEN
                CAST((xpath('FREEZELIMIT/@MAXDURATION_UNIT',
                    xmlparse(document convert_from(st.FREEZELIMIT,'UTF8'))))[1] AS VARCHAR)
            ELSE NULL
        END AS "Max duration Unit",
        pjf.PRICE AS "Joining Fee Club Level",
        pacCreation.NAME AS "Joining fee account config",
        CASE
            WHEN st.PRORATAPRODUCT_CENTER IS NOT NULL THEN 1
            ELSE 0
        END AS "Use Pro Rata Period",
        pacProRata.NAME AS "Pro rata account config",
        CASE st.AGE_RESTRICTION_TYPE
            WHEN 1 THEN 'LESS THEN'
            WHEN 2 THEN 'MORE THEN'
            ELSE 'UNDEFINED'
        END AS "age restriction type",
        st.AGE_RESTRICTION_VALUE AS "Age",
        ps.NAME AS "Privilege Set Top Level",
        st.IS_PRICE_UPDATE_EXCLUDED,

        -- ⭐ Deduplication: remove duplicates only if Global ID + Centre Name are same
        ROW_NUMBER() OVER (
            PARTITION BY prod.GLOBALID, c.NAME
            ORDER BY prod.CENTER, mpr.GLOBALID
        ) AS rn

    FROM SUBSCRIPTIONTYPES st
    JOIN PRODUCTS prod
        ON prod.CENTER = st.CENTER
       AND prod.ID = st.ID
       AND prod.blocked = 0
    JOIN CENTERS c
        ON c.id = prod.CENTER
    JOIN PRODUCT_GROUP pg
        ON pg.ID = prod.PRIMARY_PRODUCT_GROUP_ID
    JOIN PRODUCT_ACCOUNT_CONFIGURATIONS pac
        ON pac.ID = prod.PRODUCT_ACCOUNT_CONFIG_ID
    LEFT JOIN ACCOUNTS sales_acc
        ON sales_acc.GLOBALID = pac.SALES_ACCOUNT_GLOBALID
       AND sales_acc.CENTER = prod.CENTER
    JOIN MASTERPRODUCTREGISTER mpr
        ON mpr.GLOBALID = prod.GLOBALID
    LEFT JOIN PRODUCTS fp
        ON fp.CENTER = st.FREEZEPERIODPRODUCT_CENTER
       AND fp.ID = st.FREEZEPERIODPRODUCT_ID
    LEFT JOIN PRODUCTS pjf
        ON pjf.CENTER = prod.CENTER
       AND pjf.GLOBALID = 'CREATION_' || prod.GLOBALID
    LEFT JOIN PRODUCT_GROUP pgCreationPrimary
        ON pgCreationPrimary.ID = pjf.PRIMARY_PRODUCT_GROUP_ID
    LEFT JOIN PRODUCT_ACCOUNT_CONFIGURATIONS pacCreation
        ON pacCreation.ID = pjf.PRODUCT_ACCOUNT_CONFIG_ID
    LEFT JOIN ROLES r
        ON r.ID = pjf.REQUIREDROLE
    LEFT JOIN PRODUCTS pProRata
        ON pProRata.CENTER = prod.CENTER
       AND pProRata.GLOBALID = 'PRORATA_' || prod.GLOBALID
    LEFT JOIN PRODUCT_GROUP pgProRataPrimary
        ON pgProRataPrimary.ID = pProRata.PRIMARY_PRODUCT_GROUP_ID
    LEFT JOIN PRODUCT_ACCOUNT_CONFIGURATIONS pacProRata
        ON pacProRata.ID = pProRata.PRODUCT_ACCOUNT_CONFIG_ID
    LEFT JOIN PRIVILEGE_GRANTS pgr
        ON pgr.GRANTER_ID = mpr.ID
       AND pgr.GRANTER_SERVICE = 'GlobalSubscription'
       AND pgr.VALID_TO IS NULL
    LEFT JOIN PRIVILEGE_SETS ps
        ON ps.ID = pgr.PRIVILEGE_SET
    LEFT JOIN PRODUCT_AND_PRODUCT_GROUP_LINK pgLink
        ON pgLink.PRODUCT_CENTER = prod.CENTER
       AND pgLink.PRODUCT_ID = prod.ID
    LEFT JOIN PRODUCT_GROUP pgAll
        ON pgAll.ID = pgLink.PRODUCT_GROUP_ID
    LEFT JOIN PRODUCT_AND_PRODUCT_GROUP_LINK pgLinkProRata
        ON pgLinkProRata.PRODUCT_CENTER = pProRata.CENTER
       AND pgLinkProRata.PRODUCT_ID = pProRata.ID
    LEFT JOIN PRODUCT_GROUP pgAllProRata
        ON pgAllProRata.ID = pgLinkProRata.PRODUCT_GROUP_ID
    LEFT JOIN PRODUCT_AND_PRODUCT_GROUP_LINK pgLinkCreation
        ON pgLinkCreation.PRODUCT_CENTER = pjf.CENTER
       AND pgLinkCreation.PRODUCT_ID = pjf.ID
    LEFT JOIN PRODUCT_GROUP pgAllCreation
        ON pgAllCreation.ID = pgLinkCreation.PRODUCT_GROUP_ID
    JOIN LICENSES li
        ON li.CENTER_ID = c.id
       AND li.FEATURE = 'clubLead'
    LEFT JOIN TEMPLATES t
        ON mpr.CONTRACT_TEMPLATE_ID = t.ID
    WHERE
        ((mpr.SCOPE_TYPE = 'C' AND mpr.SCOPE_ID = st.CENTER)
         OR mpr.ID = mpr.DEFINITION_KEY)
        AND (pgr.ID IS NULL OR pgr.VALID_TO IS NULL)
        AND prod.center IN (:scope)
        AND li.START_DATE <= CURRENT_TIMESTAMP
        AND (li.STOP_DATE > CURRENT_TIMESTAMP OR li.STOP_DATE IS NULL)
) q
WHERE rn = 1
ORDER BY "Global Name", "center name";
