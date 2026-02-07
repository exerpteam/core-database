WITH
    params AS
    (
     SELECT
            /*+ materialize */
            c.id AS centerid, 
            c.name AS center_name, 
            co.name Country,             
            datetolongTZ(TO_CHAR($$fromDate$$, 'YYYY-MM-DD HH24:MI'),co.DEFAULTTIMEZONE) AS FromDate,
            datetolongTZ(TO_CHAR($$toDate$$, 'YYYY-MM-DD HH24:MI'),co.DEFAULTTIMEZONE) + 86400000 AS ToDate
       FROM
            centers c
       JOIN
            countries co ON co.id = c.country AND c.id in ($$scope$$)
                        
    )
SELECT
  --  params.Country "Country", 
 --   params.center_name "Center", 
  --  params.centerid "Center ID", 
 -- LONGTODATE(ART.ENTRY_TIME),
 --ar.ar_type,
 --longtodate(art.trans_time),
    longtodatec (INV.TRANS_TIME, inv.center) "Trans Time",
    INV.EMPLOYEE_CENTER ||'emp'|| INV.EMPLOYEE_ID "Sales staff", 
    PE.FULLNAME "Customer name", 
    pe.center||'p'||pe.id "Customer ID", 
    DECODE (pr.PTYPE, 1, 'Goods', 2, 'Service', 4, 'Clipcard', 5, 'Subscription creation', 6, 'Transfer', 7, 'Freeze period', 8, 'Gift card', 9, 'Free gift card', 10, 'Subscription', 12, 'Subscription pro-rata', 13, 'Subscription add-on', 14, 'Access product') "Product type", 
    pr.name "Product name", 
    IL.QUANTITY "IL_QUANTITY", 
    IL.PRODUCT_NORMAL_PRICE "Product normal price", 
    IL.TOTAL_AMOUNT "Total Amount", 
    IL.NET_AMOUNT "Net Amount",
    round(IL.TOTAL_AMOUNT / IL.QUANTITY,2) "Paid Amount",
    round(IL.PRODUCT_NORMAL_PRICE - (IL.TOTAL_AMOUNT / IL.QUANTITY),2) "Discount"
FROM
    INVOICES INV
JOIN    params ON params.CenterID = inv.center
JOIN
    INVOICE_LINES_MT IL ON INV.CENTER = IL.CENTER AND INV.ID = IL.ID
JOIN
    PRODUCTS PR ON IL.PRODUCTCENTER = PR.CENTER AND IL.PRODUCTID = PR.ID

JOIN
    EMPLOYEES EM ON INV.EMPLOYEE_CENTER = EM.CENTER AND INV.EMPLOYEE_ID = EM.ID 
JOIN
    PERSONS PE ON PE.CENTER = INV.PAYER_CENTER AND PE.ID = INV.PAYER_ID AND pe.PERSONTYPE = 2 --staff
JOIN ar_trans art ON inv. id = art.ref_id AND inv.center = art.ref_center
JOIN account_receivables acr ON acr.id = art.id AND acr.center = art.center
WHERE
    acr.AR_TYPE in (1,4 ) --Cash account, Payment account
  and   PR.PTYPE IN (1) --Goods i/p
AND INV.TRANS_TIME >= params.FromDate
AND INV.TRANS_TIME <= params.ToDate
--and inv.payer_center = 540 and inv.payer_id= 350317
ORDER BY
    INV.TRANS_TIME