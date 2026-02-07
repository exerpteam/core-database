WITH
    params AS
    (
        SELECT
            /*+ materialize */
            c.id                                                      AS centerid,
            c.name                                                    AS center_name ,
            co.name                                                      Country,
            datetolongC(TO_CHAR($$FromDate$$, 'YYYY-MM-dd HH24:MI'), c.id)                   AS FromDate,
            datetolongC(TO_CHAR($$ToDate$$, 'YYYY-MM-dd HH24:MI'), c.id) + (24*60*60*1000)-1 AS ToDate
        FROM
            centers c
        JOIN
            countries co
        ON
            co.id=c.country --and c.country='NO'
    )
SELECT
    params.Country     "Country",
    params.center_name "Center",
    params.centerid "Center ID",
    longtodatec(INV.TRANS_TIME, inv.center) "Trans Time" ,--INV_TRANS_TIME,
    --  longtodatec(INV.entry_time, inv.center)               "Entry Time" ,--INV_TRANS_TIME,
    INV.EMPLOYEE_CENTER ||'emp'|| INV.EMPLOYEE_ID "Sales staff",
    PE.FULLNAME "Customer name",
    pe.center||'p'||pe.id "Customer ID",
    DECODE(pr.PTYPE, 1, 'Goods', 2, 'Service', 4, 'Clipcard', 5, 'Subscription creation', 6,
    'Transfer', 7, 'Freeze period', 8, 'Gift card', 9, 'Free gift card', 10, 'Subscription', 12,
    'Subscription pro-rata', 13, 'Subscription add-on', 14, 'Access product') "Product type",
    pg.name "Product group",
    pr.name "Product name",
    IL.QUANTITY IL_QUANTITY,
    IL.PRODUCT_NORMAL_PRICE "Product normal price",
    IL.TOTAL_AMOUNT AS "Total Amount",
    IL.NET_AMOUNT "Net Amount" ,
    -- IL.VAT_AMOUNT "Vat Amount" ,
    IL.TOTAL_AMOUNT / IL.QUANTITY "Paid Amount" ,
    IL.PRODUCT_NORMAL_PRICE - (IL.TOTAL_AMOUNT / IL.QUANTITY) "Discount"
    -- INV2.TOTAL_AMOUNT                                          "Sponshorship Amount"
FROM
    INVOICES INV
JOIN
    params
ON
    params.CenterID = inv.center
JOIN
    INVOICE_LINES_MT IL
ON
    INV.CENTER= IL.CENTER
AND INV.ID = IL.ID
    /*LEFT JOIN
    INVOICE_LINES_MT INV2
    ON
    (inv2.CENTER = IL.SPONSOR_INVOICE_CENTER
    AND inv2.ID = IL.SPONSOR_INVOICE_ID
    AND inv2.SUBID = IL.SPONSOR_INVOICE_SUBID)*/
JOIN
    PRODUCTS PR
ON
    IL.PRODUCTCENTER = PR.CENTER
AND IL.PRODUCTID = PR.ID
JOIN
    PRODUCT_AND_PRODUCT_GROUP_LINK pgl
ON
    pr.center = pgl.product_center
AND pr.id = pgl.product_id
JOIN
    product_group pg
ON
    pg.id = pgl.product_group_id
AND pr.primary_product_group_id = pg.id
JOIN
    EMPLOYEES EM
ON
    (
        INV.EMPLOYEE_CENTER = EM.CENTER
    AND INV.EMPLOYEE_ID = EM.ID)
JOIN
    PERSONS PE
ON
    PE.CENTER = INV.PAYER_CENTER
AND PE.ID = INV.PAYER_ID
AND pe.PERSONTYPE = 2 --staff
WHERE
    
            PR.PTYPE IN ($$ptype$$) --Goods, Clipcard --i/p     
            AND IL.PRODUCT_COST IS NOT NULL
            AND INV.CENTER IN ($$CenterID$$)
            AND PR.CENTER IN ($$CenterID$$)
            AND 
                  
                        INV.TRANS_TIME >= params.FromDate 
                        AND INV.TRANS_TIME <= params.ToDate 
                   
ORDER BY INV.TRANS_TIME 
  