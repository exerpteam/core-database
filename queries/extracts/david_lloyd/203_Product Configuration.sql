-- This is the version from 2026-02-05
--  
SELECT
    prod.CENTER
    , (
    CASE prod.PTYPE
        WHEN 1
        THEN 'Retail'
        WHEN 2
        THEN 'Service'
        WHEN 4
        THEN 'Clipcard'
        WHEN 5
        THEN 'Subscription creation'
        WHEN 6
        THEN 'Transfer'
        WHEN 7
        THEN 'Freeze period'
        WHEN 8
        THEN 'Gift card'
        WHEN 9
        THEN 'Free gift card'
        WHEN 10
        THEN 'Subscription'
        WHEN 12
        THEN 'Subscription pro-rata'
        WHEN 13
        THEN 'Addon service'
    END) product_type
    , c.NAME "center name"
    , prod.GLOBALID "Global Name"
    , prod.NAME "Product Name"
	, MPR.STATE "State"
    , pac.NAME "Account Configuration"
    , sales_acc.EXTERNAL_ID AS "Sales Account"
    , r.ROLENAME "Required Role"
    , prod.NEEDS_PRIVILEGE "Purchase Require Privilege"
    , prod.SHOW_IN_SALE
    , prod.SHOW_ON_WEB
    , mpr.CACHED_PRODUCTPRICE "Top Level Price"
    , prod.PRICE "Club Price"
    , pg.NAME "sub primary Product Group"
    , prod.EXTERNAL_ID "External ID"
    , pgAll.NAME "all sub groups"
    , apd.PRICE_PERIOD_COUNT ao_price_period
    , (
    CASE apd.PRICE_PERIOD_UNIT
        WHEN 0
        THEN 'WEEK'
        WHEN 1
        THEN 'DAY'
        WHEN 2
        THEN 'MONTH'
        WHEN 3
        THEN 'YEAR'
        WHEN 4
        THEN 'HOUR'
        WHEN 5
        THEN 'MINUTE'
        WHEN 6
        THEN 'SECOND'
        ELSE 'UNDEFINED'
    END)                             AS AO_ADDON_PRICE_UNIT
    , apd.INCLUDE_HOME_CENTER           ao_include_home_center
    , apd.REQUIRED                      ao_main_requires_addon
    , apd.USE_INDIVIDUAL_PRICE          ao_USE_dynamic_price
    , apd.INCLUDE_IN_PRO_RATA_PERIOD    AO_AVAILABLE_IN_PRO_RATA_PER
    , apd.BINDING_PERIOD_COUNT          ao_BINDING_PERIOD_COUNT
    , (
    CASE apd.BINDING_PERIOD_UNIT
        WHEN 0
        THEN 'WEEK'
        WHEN 1
        THEN 'DAY'
        WHEN 2
        THEN 'MONTH'
        WHEN 3
        THEN 'YEAR'
        WHEN 4
        THEN 'HOUR'
        WHEN 5
        THEN 'MINUTE'
        WHEN 6
        THEN 'SECOND'
        ELSE 'UNDEFINED'
    END)                           ao_binding_period_unit
    , aoSubProd.CACHED_PRODUCTNAME AO_REQUIRED_SUBS_NAMES
    , addReqPG.NAME                AO_REQUIRED_PGROUPS_NAMES
    , aoFreezePROD.NAME            AO_FREE_PROD_NAME
    , ps.NAME "AO_Privilege Set Top Level"
    , prod.NEEDS_PRIVILEGE
    , e1.IDENTITY AS "Barcode"
    ,vt.globalid  AS vat_global_id
    ,vt.orig_rate AS vat_orig_rate
    ,vt.rate      AS vat_rate
FROM
    PRODUCTS prod
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
    ROLES r
ON
    r.ID = prod.REQUIREDROLE
LEFT JOIN
    PRODUCT_AND_PRODUCT_GROUP_LINK pgLink
ON
    pgLink.PRODUCT_CENTER = prod.CENTER
AND pgLink.PRODUCT_ID = prod.ID
LEFT JOIN
    PRODUCT_GROUP pgAll
ON
    pgAll.ID = pgLink.PRODUCT_GROUP_ID
LEFT JOIN
    ADD_ON_PRODUCT_DEFINITION apd
ON
    apd.ID = mpr.ID
LEFT JOIN
    ADD_ON_TO_PRODUCT_GROUP_LINK aopglink
ON
    aopglink.ADD_ON_PRODUCT_DEFINITION_ID = apd.ID
LEFT JOIN
    PRODUCT_GROUP addReqPG
ON
    addReqPG.ID = aopglink.PRODUCT_GROUP_ID
LEFT JOIN
    MASTERPRODUCTREGISTER aoFreezeMPR
ON
    aoFreezeMPR.ID = apd.FREEZE_FEE_PRODUCT_ID
LEFT JOIN
    PRODUCTS aoFreezePROD
ON
    aoFreezePROD.CENTER = prod.CENTER
AND aoFreezePROD.GLOBALID = aoFreezeMPR.GLOBALID
LEFT JOIN
    SUBSCRIPTION_ADDON_PRODUCT sap
ON
    sap.ADDON_PRODUCT_ID = apd.ID
LEFT JOIN
    MASTERPRODUCTREGISTER aoSubProd
ON
    aoSubProd.ID = sap.SUBSCRIPTION_PRODUCT_ID
LEFT JOIN
    PRIVILEGE_GRANTS pgr
ON
    pgr.GRANTER_ID = mpr.ID
AND pgr.GRANTER_SERVICE = 'Addon'
LEFT JOIN
    PRIVILEGE_SETS ps
ON
    ps.ID = pgr.PRIVILEGE_SET
LEFT JOIN
    ENTITYIDENTIFIERS e1
ON
    mpr.GLOBALID = e1.REF_GLOBALID
AND e1.SCOPE_TYPE = mpr.SCOPE_TYPE
AND e1.SCOPE_ID = mpr.SCOPE_ID
AND e1.IDMETHOD = 1
AND e1.REF_TYPE = 4
LEFT JOIN
    account_vat_type_group avtg
ON
    sales_acc.center = avtg.account_center
AND sales_acc.id = avtg.account_id
LEFT JOIN
    account_vat_type_link avtl
ON
    avtg.id = avtl.account_vat_type_group_id 
LEFT JOIN 
    vat_types vt
ON
    vt.center = avtl.vat_type_center
AND vt.id = avtl.vat_type_id
WHERE
    mpr.ID = mpr.DEFINITION_KEY
    --AND prod.PTYPE IN (1,2,13)
AND prod.PTYPE IN ($$pType$$)
AND prod.center IN ($$scope$$)
    -- AND prod.BLOCKED = 0
ORDER BY
    mpr.GLOBALID
    , prod.CENTER