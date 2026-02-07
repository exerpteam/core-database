SELECT
    prod.CENTER,
    c.NAME "center name",
    prod.GLOBALID "Global Name",
    prod.NAME "Product Name",
    prod.PRICE "Club Price",
    pg.NAME "sub primary Product Group",
ps.ID "Privilege Set ID",
  ps.NAME "Privilege Set Name",
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
JOIN
    MASTERPRODUCTREGISTER mpr
ON
    mpr.GLOBALID = prod.GLOBALID
LEFT JOIN
    PRIVILEGE_GRANTS pgr
ON
    pgr.GRANTER_ID = Prod.ID -- prod.GLOBALID
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
