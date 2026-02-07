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
    pgAll.NAME "all sub groups",
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
LEFT JOIN
    PRODUCT_GROUP pgAll
ON
    pgAll.ID = pgLink.PRODUCT_GROUP_ID
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
   
	AND pgAll.ID IN (244,248,251)
	AND prod.NAME like '%Funded%'
ORDER BY
    mpr.GLOBALID,
    prod.CENTER,
    ps.NAME