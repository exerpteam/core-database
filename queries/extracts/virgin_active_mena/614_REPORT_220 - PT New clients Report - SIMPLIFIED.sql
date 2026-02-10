-- The extract is extracted from Exerp on 2026-02-08
--  
SELECT DISTINCT
     longToDate(MAX(inv.TRANS_TIME))     invoice_created,
     invl.PERSON_CENTER || 'p' || invl.PERSON_ID user_id,
     inv.PAYER_CENTER || 'p' || inv.PAYER_ID     payer_id,
     prod.NAME PRODUCT_NAME,
     pgp.NAME                                                                                                                                                                                                        primary_product_group,
     CASE prod.PTYPE  WHEN 1 THEN  'Retail'  WHEN 2 THEN  'Service'  WHEN 4 THEN  'Clipcard'  WHEN 5 THEN  'Subscription creation'  WHEN 6 THEN  'Transfer'  WHEN 7 THEN  'Freeze period'  WHEN 8 THEN  'Gift card'  WHEN 9 THEN  'Free gift card'  WHEN 10 THEN  'Subscription'  WHEN 12 THEN  'Subscription pro-rata'  WHEN 13 THEN  'Subscription add-on' END product_type
 FROM
     invoice_lines_mt invl
 JOIN
     INVOICES inv
 ON
     inv.CENTER = invl.CENTER
     AND inv.id = invl.id
 JOIN
     PRODUCTS prod
 ON
     prod.CENTER = invl.PRODUCTCENTER
     AND prod.ID = invl.PRODUCTID
 JOIN
     PRODUCT_AND_PRODUCT_GROUP_LINK link
 ON
     link.PRODUCT_CENTER = prod.CENTER
     AND link.PRODUCT_ID = prod.ID
 JOIN
     PRODUCT_GROUP pg
 ON
     (
         pg.ID = 402
         OR pg.PARENT_PRODUCT_GROUP_ID = 402)
         and pg.STATE = 'ACTIVE'
         and pg.id = link.PRODUCT_GROUP_ID
 JOIN
     PRODUCT_GROUP pgp
 ON
     pgp.ID = prod.PRIMARY_PRODUCT_GROUP_ID
     and pgp.STATE = 'ACTIVE'
 WHERE
     prod.PTYPE NOT IN (12,5)
     AND NOT EXISTS
     (
         SELECT
             1
         FROM
             credit_note_lines_mt cnl
         WHERE
             cnl.INVOICELINE_CENTER = invl.CENTER
             AND cnl.INVOICELINE_ID = invl.ID
             AND cnl.INVOICELINE_SUBID = invl.SUBID )
             and inv.CENTER in ($$scope$$)
             and inv.TRANS_TIME between $$fromDate$$ and $$toDate$$ + (86400000-1)
 GROUP BY
     invl.PERSON_CENTER,
     invl.PERSON_ID ,
     inv.PAYER_CENTER ,
     inv.PAYER_ID ,
     prod.NAME,
     prod.CENTER,
     prod.id,
     pg.name,
     pgp.NAME ,
     prod.PTYPE
