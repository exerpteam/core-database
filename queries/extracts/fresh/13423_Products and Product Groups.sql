-- The extract is extracted from Exerp on 2026-02-08
--  
 SELECT
     distinct
     prod.globalid   as "Product Global Name",
     prod.name       as "Product Name",
     pg.name         as "Product Group Name",
     CASE PTYPE  WHEN 1 THEN  'Retail'  WHEN 2 THEN  'Service'  WHEN 4 THEN  'Clipcard'  WHEN 5 THEN  'Subscription creation'  WHEN 6 THEN  'Transfer'  WHEN 7 THEN  'Freeze period'  WHEN 8 THEN  'Gift card'  WHEN 9 THEN  'Free gift card'  WHEN 10 THEN  'Subscription'  WHEN 12 THEN  'Subscription pro-rata'  WHEN 13 THEN  'Subscription add-on' END as "Product Type"
 FROM
     products prod
 JOIN
     PRODUCT_AND_PRODUCT_GROUP_LINK pgl
 ON
     pgl.product_center = prod.center
     AND pgl.product_id = prod.id
 JOIN
     product_group pg
 ON
     pg.id = pgl.product_group_id
