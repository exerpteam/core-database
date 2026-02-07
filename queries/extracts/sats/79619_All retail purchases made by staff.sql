 WITH
     params AS
     (
      SELECT
             /*+ materialize */
             c.id AS centerid,
             c.name AS center_name,
             co.name Country,
             datetolongTZ(TO_CHAR(cast(:fromDate as date), 'YYYY-MM-DD HH24:MI'),co.DEFAULTTIMEZONE) AS FromDate,
             datetolongTZ(TO_CHAR(cast(:toDate as date), 'YYYY-MM-DD HH24:MI'),co.DEFAULTTIMEZONE) + 86400000 AS ToDate
        FROM
             centers c
        JOIN
             countries co ON co.id = c.country AND c.id in (:scope)
     )
 SELECT
     params.Country "Country",
     params.center_name "Center",
     params.centerid "Center ID",
     longtodatec (INV.TRANS_TIME, inv.center) "Trans Time",
     INV.EMPLOYEE_CENTER ||'emp'|| INV.EMPLOYEE_ID "Sales staff",
     PE.FULLNAME "Customer name",
     pe.center||'p'||pe.id "Customer ID",
     CASE  pr.PTYPE  WHEN 1 THEN  'Goods'  WHEN 2 THEN  'Service'  WHEN 4 THEN  'Clipcard'  WHEN 5 THEN  'Subscription creation'  WHEN 6 THEN  'Transfer'  WHEN 7 THEN  'Freeze period'  WHEN 8 THEN  'Gift card'  WHEN 9 THEN  'Free gift card'  WHEN 10 THEN  'Subscription'  WHEN 12 THEN  'Subscription pro-rata'  WHEN 13 THEN  'Subscription add-on'  WHEN 14 THEN  'Access product' END "Product type",
     pg.name "Product group",
     pr.name "Product name",
     IL.QUANTITY "IL_QUANTITY",
     IL.PRODUCT_NORMAL_PRICE "Product normal price",
     IL.TOTAL_AMOUNT "Total Amount",
     IL.NET_AMOUNT "Net Amount",
     round(IL.TOTAL_AMOUNT / IL.QUANTITY,2) "Paid Amount",
     round(IL.PRODUCT_NORMAL_PRICE - (IL.TOTAL_AMOUNT / IL.QUANTITY),2) "Discount"
 FROM
     INVOICES INV
 JOIN
     params ON params.CenterID = inv.center
 JOIN
     INVOICE_LINES_MT IL ON INV.CENTER = IL.CENTER AND INV.ID = IL.ID
 JOIN
     PRODUCTS PR ON IL.PRODUCTCENTER = PR.CENTER AND IL.PRODUCTID = PR.ID
 JOIN
     PRODUCT_AND_PRODUCT_GROUP_LINK pgl ON pr.center = pgl.product_center AND pr.id = pgl.product_id
 JOIN
     product_group pg ON pg.id = pgl.product_group_id AND pr.primary_product_group_id = pg.id
 JOIN
     EMPLOYEES EM ON (INV.EMPLOYEE_CENTER = EM.CENTER AND INV.EMPLOYEE_ID = EM.ID)
 JOIN
     PERSONS PE ON PE.CENTER = INV.PAYER_CENTER AND PE.ID = INV.PAYER_ID AND pe.PERSONTYPE = 2 --staff
 WHERE
     PR.PTYPE IN (1, 4) --Goods, Clipcard --i/p
 --AND IL.PRODUCT_COST IS NOT NULL
 AND INV.TRANS_TIME >= params.FromDate
 AND INV.TRANS_TIME <= params.ToDate
 ORDER BY
     INV.TRANS_TIME
