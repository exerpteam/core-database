
SELECT
    s.center || 'ss' || s.ID            sid,
    s.OWNER_CENTER || 'p' || s.OWNER_ID pid,
    exerpro.longToDate(s.CREATION_TIME) CREATED,
    s.START_DATE,
    s.END_DATE,
    s.BINDING_END_DATE,
    prod.NAME,
    DECODE (s.STATE, 2,'ACTIVE', 3,'ENDED', 4,'FROZEN', 7,'WINDOW', 8,'CREATED','UNKNOWN') as STATE,
    DECODE (s.SUB_STATE, 1,'NONE', 2,'AWAITING_ACTIVATION', 3,'UPGRADED', 4,'DOWNGRADED', 5,'EXTENDED', 6, 'TRANSFERRED',7,'REGRETTED',8,'CANCELLED',9,'BLOCKED','UNKNOWN') AS SUB_STATE,
    DECODE(st.ST_TYPE, 0, 'Cash', 1, 'EFT', 3, 'Prospect') as TYPE,
    CASE
        WHEN pg.id = 271
            OR pg.PARENT_PRODUCT_GROUP_ID = 271
        THEN 'YES'
        ELSE 'NO'
    END            AS primary_pt_prod_group,
    pg.NAME           main_sub_prod_group_name,
    sp.PRICE          current_main_sub_price,
    'ADDON IN -->'    addon_info,
    sa.ID             add_on_id,
    sa.START_DATE,
    sa.END_DATE,
    exerpro.longToDate(sa.CREATION_TIME) created,
    aopg.NAME prod_group_name,
    CASE
        WHEN aopg.id = 271
            OR aopg.PARENT_PRODUCT_GROUP_ID = 271
        THEN 'YES'
        ELSE 'NO'
    END            AS primary_pt_prod_group,    
    mpr.CACHED_PRODUCTNAME name,
    sa.USE_INDIVIDUAL_PRICE,
    sa.INDIVIDUAL_PRICE_PER_UNIT,
    sa.BINDING_END_DATE
FROM
    SUBSCRIPTIONS s
LEFT JOIN
    SUBSCRIPTION_ADDON sa
ON
    sa.SUBSCRIPTION_CENTER = s.CENTER
    AND sa.SUBSCRIPTION_ID = s.ID
    AND sa.CANCELLED = 0
LEFT JOIN
    MASTERPRODUCTREGISTER mpr
ON
    mpr.ID = sa.ADDON_PRODUCT_ID
LEFT JOIN
    PRODUCT_GROUP aopg
ON
    aopg.id = mpr.PRIMARY_PRODUCT_GROUP_ID
LEFT JOIN
    SUBSCRIPTION_PRICE sp
ON
    sp.SUBSCRIPTION_CENTER = s.CENTER
    AND sp.SUBSCRIPTION_ID = s.id
    AND sp.CANCELLED = 0
    AND sp.FROM_DATE <= SYSDATE
    AND (
        sp.TO_DATE IS NULL
        OR sp.TO_DATE > SYSDATE)
JOIN
    SUBSCRIPTIONTYPES st
ON
    st.CENTER = s.SUBSCRIPTIONTYPE_CENTER
    AND st.id = s.SUBSCRIPTIONTYPE_ID
JOIN
    PRODUCTS prod
ON
    prod.CENTER = s.SUBSCRIPTIONTYPE_CENTER
    AND prod.ID = s.SUBSCRIPTIONTYPE_ID
JOIN
    PRODUCT_GROUP pg
ON
    pg.ID = prod.PRIMARY_PRODUCT_GROUP_ID
LEFT JOIN
    PERSON_EXT_ATTRS oldid
ON
    oldid.PERSONCENTER = s.OWNER_CENTER
    AND oldid.PERSONID = s.OWNER_ID
    AND oldid.name = '_eClub_OldSystemPersonId'
LEFT JOIN
    PERSON_EXT_ATTRS created
ON
    created.PERSONCENTER = s.OWNER_CENTER
    AND created.PERSONID = s.OWNER_ID
    AND created.name = 'CREATION_DATE'
WHERE
    (
        s.OWNER_CENTER,s.OWNER_ID) IN ( $$pids$$)