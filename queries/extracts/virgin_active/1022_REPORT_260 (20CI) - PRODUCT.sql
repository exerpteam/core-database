SELECT distinct
    prod.CENTER || 'prod' || prod.ID "PRODUCTID",
    prod.CENTER || 'prod' || prod.ID "CODE",
    pg.ID "DEPARTMENT",
    prod.NAME "DESCRIPTION",
    DECODE(st.ST_TYPE,0,'FIXED_LENGTH',1,'RECURRING',NULL) "PERIODDESCRIPTION",
    to_char(prod.PRICE,'FM99999999999999999990.00') "PRICE",
    pgnp.ID "SECONDARY_PRODUCT_GROUP_ID",
    st.BINDINGPERIODCOUNT "CONTRACTLENGTH",
    prod.CENTER "SITEID",
    prodJF.PRICE "JOININGFEE",
    prodAF.PRICE "MEMBERSHIPFEE",
    DECODE(prod.PTYPE, 1, 'Retail', 2, 'Service', 4, 'Clipcard', 5, 'Subscription creation', 6, 'Transfer', 7, 'Freeze period', 8, 'Gift card', 9, 'Free gift card', 10, 'Subscription', 12, 'Subscription pro-rata') "RECORDTYPE"
FROM
    PRODUCTS prod
left JOIN PRODUCT_GROUP pg
ON
    pg.ID = prod.PRIMARY_PRODUCT_GROUP_ID
LEFT JOIN PRODUCT_AND_PRODUCT_GROUP_LINK plink
ON
    plink.PRODUCT_CENTER = prod.CENTER
    AND plink.PRODUCT_ID = prod.ID
LEFT JOIN PRODUCT_GROUP pgnp
ON
    pgnp.ID = plink.PRODUCT_GROUP_ID and pgnp.ID != pg.ID
LEFT JOIN SUBSCRIPTIONTYPES st
ON
    st.CENTER = prod.CENTER
    AND st.ID = prod.ID
LEFT JOIN PRODUCTS prodJF
ON
    prodJF.CENTER = st.PRODUCTNEW_CENTER
    AND prodJF.ID = st.PRODUCTNEW_ID
LEFT JOIN PRODUCTS prodAF
ON
    prodAF.CENTER = st.ADMINFEEPRODUCT_CENTER
    AND prodAF.ID = st.ADMINFEEPRODUCT_ID
where prod.center IN (select c.ID from CENTERS c where  c.COUNTRY = 'GB')