-- The extract is extracted from Exerp on 2026-02-08
-- List of all homekit purchases
 SELECT
     ext_sal.txtvalue as "CustomerTitle",
     p.FIRSTNAME as "CustomerFirstname",
     p.LASTNAME as  "CustomerLastname",
     ext_phone.txtvalue as "CustomerContactNumber",
     p.address1 as "AddressLine1",
     p.address2 as "AddressLine2",
     p.address3 as "AddressLine3",
     p.zipcode as "PostCode",
     inv.CENTER || 'inv' || inv.ID as "VAOrderReference",
 SUM (
         CASE
             WHEN invl.SPONSOR_INVOICE_SUBID IS NULL
             THEN 1 * invl.QUANTITY
             ELSE 0
         END )                                                                                    AS "ProductQty",
 prod.GLOBALID as "ProductCode",
     prod.name AS "ProductName",
  to_char(longtodate(inv.TRANS_TIME),'yyyy-MM-dd') as "InvoiceDate",
     to_char(longtodate(inv.TRANS_TIME),'HH24:MI') as "InvoiceTime"
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
 LEFT JOIN
                     PERSON_EXT_ATTRS ext_sal
                 ON
                     ext_sal.PERSONCENTER = p.CENTER
                     AND ext_sal.PERSONID = p.ID
                     AND ext_sal.NAME = '_eClub_Salutation'
 LEFT JOIN
                     PERSON_EXT_ATTRS ext_phone
                 ON
                     ext_phone.PERSONCENTER = p.CENTER
                     AND ext_phone.PERSONID = p.ID
                     AND ext_phone.NAME = '_eClub_PhoneSMS'
 WHERE
     --longtodate(inv.TRANS_TIME) between (sysdate-1) and (sysdate)
     --AND
                 inv.center IN (:center)
     -- AND productGroup.SHOW_IN_SHOP = 1
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
         and prod.globalid = 'HOME_WORKOUT_KIT'
 GROUP BY
     prod.name,
     prod.GLOBALID,
     REPLACE('' || prod.PRICE, '.', ','),
     inv.EMPLOYEE_CENTER,
     inv.EMPLOYEE_ID,
     staffp.fullname,
     productGroup.NAME,
     inv.CENTER,
     inv.ID,
     p.CENTER,
     p.ID,
     payer_id,
     ext_sal.txtvalue,
     ext_phone.txtvalue,
     p.FIRSTNAME,
     p.LASTNAME,
     p.address1,
     p.address2,
     p.address3,
     p.zipcode,
     CASE prod.PTYPE  WHEN 1 THEN  'Retail'  WHEN 2 THEN  'Service'  WHEN 4 THEN  'Clipcard'  WHEN 5 THEN  'Subscription creation'  WHEN 6 THEN  'Transfer'  WHEN 7 THEN  'Freeze period'  WHEN 8 THEN  'Gift card'  WHEN 9 THEN  'Free gift card'  WHEN 10 THEN  'Subscription'  WHEN 12 THEN  'Subscription pro-rata' END,
      to_char(longtodate(inv.TRANS_TIME),'yyyy-MM-dd') ,
     to_char(longtodate(inv.TRANS_TIME),'HH24:MI')
 ORDER BY
     prod.GLOBALID
