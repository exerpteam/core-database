WITH
    params AS
    (
     SELECT
            /*+ materialize */
            c.id AS centerid, 
            c.name AS center_name, 
            co.name Country, 
            datetolongC (TO_CHAR (to_date ('2020-12-01', 'YYYY-MM-DD'), 'YYYY-MM-DD HH24:MI'), c.ID) AS FromDate, 
            datetolongC (TO_CHAR (to_date ('2021-11-30', 'YYYY-MM-DD'), 'YYYY-MM-DD HH24:MI'), c.ID) AS ToDate
       FROM
            centers c
       JOIN
            countries co ON co.id = c.country AND c.country = 'NO'
        
    )
SELECT
    params.Country "Country", 
    params.center_name "Center", 
    params.centerid "Center ID", 
    longtodatec (INV.TRANS_TIME, inv.center) "Trans Time",
    INV.EMPLOYEE_CENTER ||'emp'|| INV.EMPLOYEE_ID "Sales staff", 
    PE.FULLNAME "Customer name", 
    pe.center||'p'||pe.id "Customer ID", 
    DECODE (pr.PTYPE, 1, 'Goods', 2, 'Service', 4, 'Clipcard', 5, 'Subscription creation', 6, 'Transfer', 7, 'Freeze 	period', 8, 'Gift card', 9, 'Free gift card', 10, 'Subscription', 12, 'Subscription pro-rata', 13, 'Subscription 	add-on', 14, 'Access product') "Product type", 
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
    PR.PTYPE IN (1, 4) --Goods, Clipcard
    
--AND IL.PRODUCT_COST IS NOT NULL
AND INV.TRANS_TIME >= params.FromDate
AND INV.TRANS_TIME <= params.ToDate

ORDER BY
    INV.TRANS_TIME