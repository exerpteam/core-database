 SELECT DISTINCT
     prod.CENTER PROD_CENTER,
     prod.NAME PROD_NAME,
     pg.ID   PG_ID,
     pg.NAME PG_NAME
 FROM
     PRODUCTS prod
 JOIN
     PRODUCT_GROUP pg
 ON
     pg.id = prod.PRIMARY_PRODUCT_GROUP_ID
 WHERE
     prod.BLOCKED = 0
         and prod.center in ($$scope$$)
