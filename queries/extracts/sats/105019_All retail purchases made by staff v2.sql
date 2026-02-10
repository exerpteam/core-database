-- The extract is extracted from Exerp on 2026-02-08
--  
 WITH
        params AS materialized
             (
              SELECT                    
                     c.id AS centerid,
                     c.name AS center_name,
                     co.name Country,
                     datetolongC(TO_CHAR((:FromDate)::date, 'YYYY-MM-DD HH24:MI'),c.id)::bigint AS FromDate,
                     datetolongC(TO_CHAR((:ToDate)::date, 'YYYY-MM-DD HH24:MI'),c.id)::bigint + 86399999 AS ToDate               
                FROM
                     centers c
                JOIN
                     countries co ON co.id = c.country ---AND c.country = 'NO' 
and c.id in (:scope)

    ),
        staff_invoice AS materialized
                (
                SELECT
                        longtodatec (INV.TRANS_TIME, inv.center) "Trans Time",
                        INV.EMPLOYEE_CENTER ||'emp'|| INV.EMPLOYEE_ID "Sales staff",
                        PE.FULLNAME "Customer name",
                        pe.center||'p'||pe.id "Customer ID",
                        inv.center,
                        inv.id,
                        inv.trans_time,
                        params.Country "Country",
                        params.center_name "Center Name",
                        params.centerid "Center ID"       
                 FROM
                     INVOICES INV
                 JOIN
                     params ON params.CenterID = inv.center     
                 JOIN
                     PERSONS PE ON PE.CENTER = INV.PAYER_CENTER AND PE.ID = INV.PAYER_ID AND pe.PERSONTYPE = 2 --staff     
                 JOIN
                     EMPLOYEES EM ON INV.EMPLOYEE_CENTER = EM.CENTER AND INV.EMPLOYEE_ID = EM.ID
                     
                WHERE 
                        INV.TRANS_TIME >= params.FromDate
                        AND INV.TRANS_TIME <= params.ToDate 
    )
 
 SELECT
     SInv."Country",
     SInv."Center Name",
     SInv."Center ID",
     SInv."Trans Time",
     SInv."Sales staff",
     SInv."Customer name",
     sInv."Customer ID",
     CASE  pr.PTYPE  
        WHEN 1 THEN  'Goods'  WHEN 2 THEN  'Service'  WHEN 4 THEN  'Clipcard'  
        WHEN 5 THEN  'Subscription creation'  WHEN 6 THEN  'Transfer' WHEN 7 THEN  'Freeze period'  
        WHEN 8 THEN  'Gift card'  WHEN 9 THEN  'Free gift card'  WHEN 10 THEN  'Subscription'  
        WHEN 12 THEN  'Subscription pro-rata'  WHEN 13 THEN  'Subscription add-on'  WHEN 14 THEN  'Access product' 
     END "Product type",
     pg.name "Product group",
     pr.name "Product name",
     IL.QUANTITY "IL_QUANTITY",
     IL.PRODUCT_NORMAL_PRICE "Product normal price",
     IL.TOTAL_AMOUNT "Total Amount",
     IL.NET_AMOUNT "Net Amount",
     round(IL.TOTAL_AMOUNT / IL.QUANTITY,2) "Paid Amount",
     round(IL.PRODUCT_NORMAL_PRICE - (IL.TOTAL_AMOUNT / IL.QUANTITY),2) "Discount"
     
 FROM
     staff_invoice sINV
 JOIN
     INVOICE_LINES_MT IL ON sINV.CENTER = IL.CENTER AND sINV.ID = IL.ID
 JOIN
     PRODUCTS PR ON IL.PRODUCTCENTER = PR.CENTER AND IL.PRODUCTID = PR.ID
 JOIN
     PRODUCT_AND_PRODUCT_GROUP_LINK pgl ON pr.center = pgl.product_center AND pr.id = pgl.product_id
 JOIN
     product_group pg ON pg.id = pgl.product_group_id AND pr.primary_product_group_id = pg.id
 
 WHERE
     PR.PTYPE IN (1, 4) --Goods, Clipcard

 ORDER BY
     sINV.TRANS_TIME