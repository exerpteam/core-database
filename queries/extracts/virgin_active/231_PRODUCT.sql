SELECT
    prod.CENTER || 'prod' || prod.ID "PRODUCTID",
    'Bar code?' "CODE",
    'N/A' "DEPARTMENT",
    prod.COMENT "DESCRIPTION",
    'Needs clarification' "PERIODDESCRIPTION",
    prod.PRICE "PRICE",
    'N/A' "PACKAGECATEGORY",
    'N/A' "PACKAGETYPE",
    st.BINDINGPERIODCOUNT "CONTRACTLENGTH",
    'N/A' "PACKAGETYPEKPI",
    'N/A' "RACQUETSMEMBER",
    'N/A' "SALESHEADS",
    prod.CENTER "SITEID",
    'N/A' "CLASSID",
    prodJF.PRICE "JOININGFEE",
    prodAF.PRICE "MEMBERSHIPFEE",
    'N/A' "MEMBERSHIPFEEH",
    'N/A' "CONTRACTPRICE",
    'N/A' "CREATEDDATE",
    DECODE(prod.PTYPE, 1, 'Retail', 2, 'Service', 4, 'Clipcard', 5, 'Subscription creation', 6, 'Transfer', 7, 'Freeze period', 8, 'Gift card', 9, 'Free gift card', 10, 'Subscription', 12, 'Subscription pro-rata') "RECORDTYPE",
    'EXERP' "SOURCESYSTEM",
    '?' "EXTREF"
FROM
    PRODUCTS prod
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
