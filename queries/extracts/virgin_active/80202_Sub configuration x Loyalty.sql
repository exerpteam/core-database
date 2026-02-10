-- The extract is extracted from Exerp on 2026-02-08
--  
 select distinct * from (
 SELECT
     prod.NAME "Product Name",
     r.ROLENAME "Required Role",
     st.RANK "Rank",
     CASE st.ST_TYPE WHEN 0 THEN 'CASH' WHEN 1 THEN 'EFT' ELSE 'UNDEFINED' END "Deduction",
     CASE
        WHEN POSITION('A-Age Excluded-capi-loyalty' IN STRING_AGG(DISTINCT pgAll.NAME, ' ; ')) > 0 THEN 'A-Age Excluded-capi-loyalty'
        WHEN POSITION('E-Excluded-capi-loyalty' IN STRING_AGG(DISTINCT pgAll.NAME, ' ; ')) > 0 THEN 'E-Excluded-capi-loyalty'
        WHEN POSITION('F-Full Loyalty-capi-loyalty' IN STRING_AGG(DISTINCT pgAll.NAME, ' ; ')) > 0 THEN 'F-Full Loyalty-capi-loyalty'
        WHEN POSITION('W-Weekly Reward Only-capi-loyalty' IN STRING_AGG(DISTINCT pgAll.NAME, ' ; ')) > 0 THEN 'W-Weekly Reward Only-capi-loyalty'
        ELSE NULL
    END AS "Loyalty Product Group"
 FROM
     SUBSCRIPTIONTYPES st
 JOIN
     PRODUCTS prod
 ON
     prod.CENTER = st.CENTER
     AND prod.ID = st.ID
         and prod.blocked = 0
 JOIN
     CENTERS c
 ON
     c.id = prod.CENTER
 JOIN
     PRODUCT_GROUP pg
 ON
     pg.ID = prod.PRIMARY_PRODUCT_GROUP_ID
 JOIN
     MASTERPRODUCTREGISTER mpr
 ON
     mpr.GLOBALID = prod.GLOBALID
 LEFT JOIN
     PRODUCTS pjf
 ON
     pjf.CENTER = prod.CENTER
     AND pjf.GLOBALID = 'CREATION_' || prod.GLOBALID
 LEFT JOIN
     ROLES r
 ON
     r.ID = pjf.REQUIREDROLE
 LEFT JOIN
     PRODUCT_AND_PRODUCT_GROUP_LINK pgLink
 ON
     pgLink.PRODUCT_CENTER = prod.CENTER
     AND pgLink.PRODUCT_ID = prod.ID
 LEFT JOIN
     PRODUCT_GROUP pgAll
 ON
     pgAll.ID = pgLink.PRODUCT_GROUP_ID
 WHERE
     prod.center IN (:scope)
 GROUP BY
  prod.NAME, r.ROLENAME, st.RANK, st.ST_TYPE
 ORDER BY
     prod.name) t1
