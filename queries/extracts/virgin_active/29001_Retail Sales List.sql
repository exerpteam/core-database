SELECT 
   c.NAME, 
   p.NAME,
   TO_CHAR(longtodateC(i.TRANS_TIME, i.CENTER), 'YYYY-MM-DD HH24:MI:SS') "TRANS_DATE_TIME",
   il.QUANTITY, 
   il.TOTAL_AMOUNT, 
   il.PRODUCT_COST,  
   (il.TOTAL_AMOUNT - il.PRODUCT_COST) As Profit, 
   CASE il.TOTAL_AMOUNT
     WHEN 0 THEN null 
     ELSE ROUND(100 * (il.TOTAL_AMOUNT - il.PRODUCT_COST) / il.TOTAL_AMOUNT,2) || ' %' 
   END AS "Profit%",  
   CASE il.QUANTITY
     WHEN 0 THEN null 
     ELSE ROUND((il.TOTAL_AMOUNT - il.PRODUCT_COST) / il.QUANTITY,2)
   END AS Profit_Per_Unit 
FROM 
  INVOICES i
JOIN
  INVOICE_LINES_MT il
ON
  il.center = i.center
  AND il.id = i.id
JOIN
  PRODUCTS p
ON
  il.PRODUCTCENTER = p.CENTER 
  AND il.PRODUCTID = p.ID
JOIN
  CENTERS c
ON
  c.ID = il.CENTER
WHERE
  p.PTYPE = 1
  AND c.ID IN (:Scope)
  AND i.TRANS_TIME BETWEEN (:FromDate) AND (:ToDate)
UNION ALL  
SELECT
   c.NAME, 
   prod.NAME,
   TO_CHAR(longtodateC(cn.TRANS_TIME, cn.CENTER), 'YYYY-MM-DD HH24:MI:SS') "TRANS_DATE_TIME",
   cl.QUANTITY, 
   cl.TOTAL_AMOUNT, 
   cl.PRODUCT_COST,  
   (cl.TOTAL_AMOUNT - cl.PRODUCT_COST) As Profit, 
   CASE cl.TOTAL_AMOUNT
     WHEN 0 THEN null 
     ELSE ROUND(100 * (cl.TOTAL_AMOUNT - cl.PRODUCT_COST) / cl.TOTAL_AMOUNT,2) || ' %' 
   END AS "Profit%",  
   CASE cl.QUANTITY
     WHEN 0 THEN null 
     ELSE ROUND((cl.TOTAL_AMOUNT - cl.PRODUCT_COST) / cl.QUANTITY,2)
   END AS Profit_Per_Unit 
FROM
    CREDIT_NOTES cn
JOIN
    credit_note_lines_mt cl
ON
    cl.center = cn.center
    AND cl.id = cn.id
JOIN
    PRODUCTS prod
ON
    prod.center = cl.PRODUCTCENTER
    AND prod.id = cl.PRODUCTID
JOIN
  CENTERS c
ON
  c.ID = cl.CENTER
WHERE
  prod.PTYPE = 1 
  AND c.ID IN (:Scope)
  AND cn.TRANS_TIME BETWEEN (:FromDate) AND (:ToDate)
