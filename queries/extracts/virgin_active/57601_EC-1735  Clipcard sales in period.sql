-- The extract is extracted from Exerp on 2026-02-08
--  
 SELECT
     productGroup.NAME product_group_name,
     p.CENTER || 'p' || p.ID payer_id,
     p.FIRSTNAME || ' ' || p.LASTNAME payer_name,
     prod.GLOBALID product,
     prod.name AS product_name,
     CASE prod.PTYPE  WHEN 1 THEN  'Retail'  WHEN 2 THEN  'Service'  WHEN 4 THEN  'Clipcard'  WHEN 5 THEN  'Subscription creation'  WHEN 6 THEN  'Transfer'  WHEN 7 THEN  'Freeze period'  WHEN 8 THEN  'Gift card'  WHEN 9 THEN  'Free gift card'  WHEN 10 THEN  'Subscription'  WHEN 12 THEN  'Subscription pro-rata' END product_type,
     inv.EMPLOYEE_CENTER||'emp'||inv.EMPLOYEE_ID                                                  AS staff,
     staffp.fullname                                                                              AS staff_name,
     to_char(longtodate(inv.TRANS_TIME),'yyyy-MM-dd') as "Invoice Date",
     to_char(longtodate(inv.TRANS_TIME),'HH24:MI') as "Invoice Time"
 FROM
     INVOICELINES invl
 JOIN INVOICES inv
 ON
     invl.CENTER = inv.CENTER
     AND invl.id = inv.id
 LEFT JOIN PERSONS p
 ON
     p.CENTER = inv.PAYER_CENTER
     AND p.ID = inv.PAYER_ID
 JOIN CENTERS c
 ON
     c.id = invl.CENTER
 JOIN PRODUCTS prod
 ON
     prod.ID = invl.PRODUCTID
     AND prod.CENTER = invl.PRODUCTCENTER
 JOIN PRODUCT_GROUP productGroup
 ON
     prod.PRIMARY_PRODUCT_GROUP_ID = productGroup.id
 LEFT JOIN employees staff
 ON
     inv.EMPLOYEE_CENTER = staff.center
     AND inv.EMPLOYEE_ID = staff.id
 LEFT JOIN persons staffp
 ON
     staff.personcenter = staffp.center
     AND staff.personid = staffp.id
 WHERE
     inv.TRANS_TIME >= :time_from
     AND inv.TRANS_TIME < :time_to
     AND inv.center IN (:center)
     AND NOT EXISTS
     (
         SELECT
             *
         FROM
             CREDIT_NOTE_LINES cnl
         WHERE
             cnl.INVOICELINE_CENTER = invl.CENTER
             AND cnl.INVOICELINE_ID = invl.id
             AND cnl.INVOICELINE_SUBID = invl.SUBID
     )
         and prod.PTYPE in (4)
 GROUP BY
     prod.name,
     prod.GLOBALID,
     REPLACE('' || prod.PRICE, '.', ','),
     inv.EMPLOYEE_CENTER,
     inv.EMPLOYEE_ID,
     staffp.fullname,
     productGroup.NAME,
     p.CENTER,
     p.ID,
     payer_id,
     p.FIRSTNAME,
     p.LASTNAME,
     CASE prod.PTYPE  WHEN 1 THEN  'Retail'  WHEN 2 THEN  'Service'  WHEN 4 THEN  'Clipcard'  WHEN 5 THEN  'Subscription creation'  WHEN 6 THEN  'Transfer'  WHEN 7 THEN  'Freeze period'  WHEN 8 THEN  'Gift card'  WHEN 9 THEN  'Free gift card'  WHEN 10 THEN  'Subscription'  WHEN 12 THEN  'Subscription pro-rata' END,
      to_char(longtodate(inv.TRANS_TIME),'yyyy-MM-dd') ,
     to_char(longtodate(inv.TRANS_TIME),'HH24:MI')
 ORDER BY
     prod.GLOBALID
