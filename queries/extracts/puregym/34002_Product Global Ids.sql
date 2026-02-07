 SELECT
     prod.center     as "Product Center Id",
     c.shortname     as "Product Center Name",
     prod.globalid   as "Product Global ID",
     prod.name       as "Product Name",
     pg.name         as "Product Group Name",
     st.rank,
     prod.external_id,
     CASE 
     WHEN st.periodunit = 0
     THEN 'WEEK'
     WHEN st.periodunit = 1 
     THEN 'DAY'
     WHEN st.periodunit = 2
     THEN 'MONTH'
     WHEN st.periodunit = 3
     THEN 'YEAR'
     WHEN st.periodunit = 4
     THEN 'HOUR'
     WHEN st.periodunit = 5
     THEN 'MINUTE'
     WHEN st.periodunit = 6
     THEN 'SECOND'
     ELSE 'UNDEFINED'
     END AS  "Period Unit",
     st.periodcount,
     pac.name AS "Account Configuration",
     prod.price,
     joiningfee.price as "Joining Fee",
     CASE WHEN prod.blocked = 0
     THEN 'True'
     WHEN prod.blocked = 1
     THEN 'Fasle'
     END  as "Product Availability"
 FROM
     products prod
 JOIN
     centers c
 ON
     c.id = prod.center
 JOIN
     product_group pg
 ON
     pg.id = prod.primary_product_group_id
 JOIN
    subscriptiontypes st
 ON
    st.center = prod.center
    AND st.id = prod.id
 JOIN
    PRODUCT_ACCOUNT_CONFIGURATIONS pac
 ON
     pac.ID = prod.PRODUCT_ACCOUNT_CONFIG_ID
 JOIN
     products joiningfee
 ON
     joiningfee.center = st.productnew_center
     AND joiningfee.id = st.productnew_id
 ORDER BY 3
