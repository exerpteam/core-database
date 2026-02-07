SELECT 
    prod.CENTER,
    c.NAME "center name",
    prod.GLOBALID "Global Name",
    prod.NAME "Product Name",
    pac.NAME "Account Configuration",
    sales_acc.EXTERNAL_ID AS "Sales Account",
    r.ROLENAME "Required Role",
    pjf.NEEDS_PRIVILEGE "Purchase Require Privilege",
    mpr.CACHED_PRODUCTPRICE "Top Level Price",
    prod.PRICE "Club Price",
    st.RANK                                         "Rank",
    DECODE(st.ST_TYPE,0,'CASH',1,'EFT','UNDEFINED') "Deduction",
    DECODE(st.PERIODUNIT, 0,'WEEK',1,'DAY',2,'MONTH',3,'YEAR',4,'HOUR',5,'MINUTE',6,'SECOND','UNDEFINED') "Period Unit",
    st.EXTEND_BINDING_BY_PRORATA "Ext. bind By prorata",
    st.IS_ADDON_SUBSCRIPTION "Requires Main Subscription",
    mpr.USE_CONTRACT_TEMPLATE "Use Contract Template",
    st.RENEW_WINDOW "Renew Period",
    st.PERIODCOUNT "Period Count",
    pg.NAME "sub primary Product Group",
    --pgAll.NAME "all sub groups",
    pgProRataPrimary.NAME "primary pro rata group",
    pgAllProRata.NAME "all pro rata groups",
    pgCreationPrimary.NAME "primary creation group",
    pgAllCreation.NAME "all creation groups",
    st.BINDINGPERIODCOUNT "Binding Period",
    st.PRORATAPERIODCOUNT "Prorata p.",
    st.INITIALPERIODCOUNT "Initial p.",
    fp.PRICE "Price During Freeze",
    CASE
        WHEN st.FREEZELIMIT IS NULL
        THEN 0
        ELSE 1
    END AS "can be frozen",
    CASE
        WHEN st.FREEZELIMIT IS NOT NULL
        THEN extractvalue(xmltype(st.FREEZELIMIT,nls_charset_id('AL32UTF8')),'FREEZELIMIT/FREEZEAPPLYPERIOD/FREEZEDURATION/@LENGTH') || ' ' || extractvalue(xmltype(st.FREEZELIMIT,nls_charset_id('AL32UTF8')),'FREEZELIMIT/FREEZEAPPLYPERIOD/FREEZEDURATION/@UNIT')
        ELSE NULL
    END AS "Within a period of",
    CASE
        WHEN st.FREEZELIMIT IS NOT NULL
        THEN extractvalue(xmltype(st.FREEZELIMIT,nls_charset_id('AL32UTF8')),'FREEZELIMIT/@MINDURATION')
        ELSE NULL
    END AS "Min duration",
    CASE
        WHEN st.FREEZELIMIT IS NOT NULL
        THEN extractvalue(xmltype(st.FREEZELIMIT,nls_charset_id('AL32UTF8')),'FREEZELIMIT/@MINDURATION_UNIT')
        ELSE NULL
    END AS "Min duration Unit",
    CASE
        WHEN st.FREEZELIMIT IS NOT NULL
        THEN extractvalue(xmltype(st.FREEZELIMIT,nls_charset_id('AL32UTF8')),'FREEZELIMIT/@MAXDURATION')
        ELSE NULL
    END AS "Max duration",
    CASE
        WHEN st.FREEZELIMIT IS NOT NULL
        THEN extractvalue(xmltype(st.FREEZELIMIT,nls_charset_id('AL32UTF8')),'FREEZELIMIT/@MAXDURATION_UNIT')
        ELSE NULL
    END AS "Max duration Unit",
    pjf.PRICE "Joining Fee Club Level",
    pacCreation.NAME "Joining fee account config" ,
    CASE
        WHEN st.PRORATAPRODUCT_CENTER IS NOT NULL
        THEN 1
        ELSE 0
    END AS "Use Pro Rata Period",
    pacProRata.NAME "Pro rata account config",
    DECODE(st.AGE_RESTRICTION_TYPE,1,'LESS THEN',2,'MORE THEN','UNDEFINED') "age restriction type",
    st.AGE_RESTRICTION_VALUE "Age",
    ps.NAME "Privilege Set Top Level",
    st.IS_PRICE_UPDATE_EXCLUDED
FROM
    SUBSCRIPTIONTYPES st
JOIN
    PRODUCTS prod
ON
    prod.CENTER = st.CENTER
    AND prod.ID = st.ID
JOIN
    CENTERS c
ON
    c.id = prod.CENTER
JOIN
    PRODUCT_GROUP pg
ON
    pg.ID = prod.PRIMARY_PRODUCT_GROUP_ID
JOIN
    PRODUCT_ACCOUNT_CONFIGURATIONS pac
ON
    pac.ID = prod.PRODUCT_ACCOUNT_CONFIG_ID
LEFT JOIN
    ACCOUNTS sales_acc
ON
    sales_acc.GLOBALID = pac.SALES_ACCOUNT_GLOBALID
    AND sales_acc.CENTER = prod.CENTER
JOIN
    MASTERPRODUCTREGISTER mpr
ON
    mpr.GLOBALID = prod.GLOBALID
LEFT JOIN
    PRODUCTS fp
ON
    fp.CENTER = st.FREEZEPERIODPRODUCT_CENTER
    AND fp.ID = st.FREEZEPERIODPRODUCT_ID
LEFT JOIN
    PRODUCTS pjf
ON
    pjf.CENTER = prod.CENTER
    AND pjf.GLOBALID = 'CREATION_' || prod.GLOBALID
LEFT JOIN
    PRODUCT_GROUP pgCreationPrimary
ON
    pgCreationPrimary.ID = pjf.PRIMARY_PRODUCT_GROUP_ID
LEFT JOIN
    PRODUCT_ACCOUNT_CONFIGURATIONS pacCreation
ON
    pacCreation.ID = pjf.PRODUCT_ACCOUNT_CONFIG_ID
LEFT JOIN
    ROLES r
ON
    r.ID = pjf.REQUIREDROLE
LEFT JOIN
    PRODUCTS pProRata
ON
    pProRata.CENTER = prod.CENTER
    AND pProRata.GLOBALID = 'PRORATA_' || prod.GLOBALID
LEFT JOIN
    PRODUCT_GROUP pgProRataPrimary
ON
    pgProRataPrimary.ID = pProRata.PRIMARY_PRODUCT_GROUP_ID
LEFT JOIN
    PRODUCT_ACCOUNT_CONFIGURATIONS pacProRata
ON
    pacProRata.ID = pProRata.PRODUCT_ACCOUNT_CONFIG_ID
LEFT JOIN
    PRIVILEGE_GRANTS pgr
ON
    pgr.GRANTER_ID = mpr.ID
    AND pgr.GRANTER_SERVICE = 'GlobalSubscription'
LEFT JOIN
    PRIVILEGE_SETS ps
ON
    ps.ID = pgr.PRIVILEGE_SET
LEFT JOIN
    PRODUCT_AND_PRODUCT_GROUP_LINK pgLink
ON
    pgLink.PRODUCT_CENTER = prod.CENTER
    AND pgLink.PRODUCT_ID = prod.ID
--LEFT JOIN
--    PRODUCT_GROUP pgAll
--ON
--    pgAll.ID = pgLink.PRODUCT_GROUP_ID
LEFT JOIN
    PRODUCT_AND_PRODUCT_GROUP_LINK pgLinkProRata
ON
    pgLinkProRata.PRODUCT_CENTER = pProRata.CENTER
    AND pgLinkProRata.PRODUCT_ID = pProRata.ID
LEFT JOIN
    PRODUCT_GROUP pgAllProRata
ON
    pgAllProRata.ID = pgLinkProRata.PRODUCT_GROUP_ID
LEFT JOIN
    PRODUCT_AND_PRODUCT_GROUP_LINK pgLinkCreation
ON
    pgLinkCreation.PRODUCT_CENTER = pjf.CENTER
    AND pgLinkCreation.PRODUCT_ID = pjf.ID
LEFT JOIN
    PRODUCT_GROUP pgAllCreation
ON
    pgAllCreation.ID = pgLinkCreation.PRODUCT_GROUP_ID
JOIN
    LICENSES li
ON
    li.CENTER_ID = c.id
    AND li.FEATURE = 'clubLead'
WHERE
    mpr.ID = mpr.DEFINITION_KEY
    AND (
        pgr.ID IS NULL
        OR pgr.VALID_TO IS NULL )
    AND prod.center IN (:scope)
    AND(
        li.START_DATE <= SYSDATE
        AND (
            li.STOP_DATE > SYSDATE
            OR li.STOP_DATE IS NULL))
   AND Pg.Parent_Product_Group_ID in (5404,206) -- Parent Group for all Mem Cat Product groups
   AND 
		ps.PRIVILEGE_SET_GROUPS_ID = '201' -- UK Access Privilege set
ORDER BY
    mpr.GLOBALID,
    prod.CENTER,
    ps.NAME