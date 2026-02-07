 SELECT DISTINCT
     inv.CENTER || 'inv' || inv.ID       inv_id,
     longToDate(inv.TRANS_TIME ) sales_date,
     p.CENTER || 'p' || p.ID             pid,
     p.FIRSTNAME,
     p.LASTNAME,
     c.NAME    center_name,
     prod.NAME product_name,
     invl.TEXT
 FROM
     INVOICELINES invl
 JOIN
     INVOICES inv
 ON
     inv.CENTER = invl.CENTER
     AND inv.id = invl.id
 JOIN
     PERSONS p
 ON
     p.CENTER = inv.PAYER_CENTER
     AND p.id = inv.PAYER_ID
 JOIN
     CENTERS c
 ON
     c.id = p.CENTER
 LEFT JOIN
     PRODUCTS prod
 ON
     prod.CENTER = invl.PRODUCTCENTER
     AND prod.ID = invl.PRODUCTID
 WHERE
     /* Who to include */
     --and cc.VALID_UNTIL > dateToLongC(to_char(sysdate, 'YYYY-MM-dd HH24:MI'),cc.center)
     (
         prod.CENTER,prod.ID ) IN
     (
         SELECT
             link.PRODUCT_CENTER,
             link.PRODUCT_ID
         FROM
             PRODUCT_AND_PRODUCT_GROUP_LINK link
         JOIN
             PRODUCT_GROUP pg
         ON
             pg.ID = link.PRODUCT_GROUP_ID
             AND pg.ID IN (271,280) )
     AND inv.TRANS_TIME BETWEEN dateToLong(TO_CHAR(add_months(CURRENT_TIMESTAMP,-3),'YYYY-MM-dd HH24:MI')) AND dateToLong(TO_CHAR(CURRENT_TIMESTAMP,'YYYY-MM-dd HH24:MI'))
