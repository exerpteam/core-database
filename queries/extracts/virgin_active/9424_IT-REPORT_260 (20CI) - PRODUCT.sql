-- The extract is extracted from Exerp on 2026-02-08
--  
 SELECT distinct
     prod.CENTER || 'prod' || prod.ID "PRODUCTID",
     prod.CENTER || 'prod' || prod.ID "CODE",
     pg.ID "DEPARTMENT",
     prod.NAME "DESCRIPTION",
     CASE st.ST_TYPE WHEN 0 THEN 'FIXED_LENGTH' WHEN 1 THEN 'RECURRING' ELSE NULL END "PERIODDESCRIPTION",
     to_char(prod.PRICE,'FM99999999999999999990.00') "PRICE",
     prod.PRIMARY_PRODUCT_GROUP_ID AS "PRIMARY_PRODUCT_GROUP_ID",
     pgnp.ID "SECONDARY_PRODUCT_GROUP_ID",
     st.BINDINGPERIODCOUNT "CONTRACTLENGTH",
     prod.CENTER "SITEID",
     prodJF.PRICE "JOININGFEE",
     prodAF.PRICE "MEMBERSHIPFEE",
     CASE prod.PTYPE  WHEN 1 THEN  'Retail'  WHEN 2 THEN  'Service'  WHEN 4 THEN  'Clipcard'  WHEN 5 THEN  'Subscription creation'  WHEN 6 THEN  'Transfer'  WHEN 7 THEN  'Freeze period'  WHEN 8 THEN  'Gift card'  WHEN 9 THEN  'Free gift card'  WHEN 10 THEN  'Subscription'  WHEN 12 THEN  'Subscription pro-rata' END "RECORDTYPE"
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
 where prod.center IN (select c.ID from CENTERS c where  c.COUNTRY = 'IT')
