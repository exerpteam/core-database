 SELECT
     'NO nutramino free startup campaign' AS "Campaign Name",
     '14.12.2017' AS "Campaign start date",
     '01.06.2018' AS "Campaign end date",
     p.CENTER AS "Member's Home Centre ID",
     c.SHORTNAME AS "Member's Home Centre Name",
     p.FULLNAME AS "Member full name",
     p.CENTER||'p'||p.ID AS "Member ID",
     TO_CHAR(ss.SALES_DATE,'DD.MM.YYYY') AS "Date of subscription purchase",
     CASE ss.SUBSCRIPTION_TYPE_TYPE  WHEN 0 THEN  'Cash'  WHEN 1 THEN  'EFT'  WHEN 3 THEN  'Prospect' END AS "Type of subscription",
     seller1.FULLNAME AS "Subscription sold by",
     pg.NAME AS "Product Group",
     pr.NAME AS "Product Name",
     center_sold.SHORTNAME AS "Place of purchase",
     TO_CHAR(longtodateC(i.TRANS_TIME, i.CENTER), 'YYYY-MM-DD HH24:MI:SS') AS "Time of purchase",
     seller2.FULLNAME AS "Product sold by",
     il.PRODUCT_NORMAL_PRICE AS "Product original cost",
     il.TOTAL_AMOUNT AS "Product actual cost"
 FROM
     PRIVILEGE_USAGES pu
 JOIN
     PERSONS p
 ON
     p.CENTER = pu.PERSON_CENTER
     AND p.ID = pu.PERSON_ID
 JOIN
     CENTERS c
 ON
     p.CENTER = c.ID
 JOIN
     SUBSCRIPTION_SALES ss
 ON
     ss.SUBSCRIPTION_CENTER = pu.SOURCE_CENTER
     AND ss.SUBSCRIPTION_ID = pu.SOURCE_ID
 JOIN
     EMPLOYEES emp
 ON
     ss.EMPLOYEE_CENTER = emp.CENTER
     AND ss.EMPLOYEE_ID = emp.ID
 JOIN
     PERSONS seller1
 ON
     seller1.CENTER = emp.PERSONCENTER
     AND seller1.ID = emp.PERSONID
 JOIN
     INVOICE_LINES_MT il
 ON
     il.CENTER = pu.TARGET_CENTER
     AND il.ID = pu.TARGET_ID
     AND il.SUBID = pu.TARGET_SUBID
 JOIN
     INVOICES i
 ON
     i.CENTER = pu.TARGET_CENTER
     AND i.ID = pu.TARGET_ID
 JOIN
     EMPLOYEES emp2
 ON
     i.EMPLOYEE_CENTER = emp2.CENTER
     AND i.EMPLOYEE_ID = emp2.ID
 JOIN
     PERSONS seller2
 ON
     seller2.CENTER = emp2.PERSONCENTER
     AND seller2.ID = emp2.PERSONID
 JOIN
     CENTERS center_sold
 ON
     center_sold.ID = i.CASHREGISTER_CENTER
 JOIN
     PRODUCTS pr
 ON
     pr.CENTER = il.PRODUCTCENTER
     AND pr.ID = il.PRODUCTID
 JOIN
     PRODUCT_AND_PRODUCT_GROUP_LINK pl
 ON
     pr.CENTER = pl.PRODUCT_CENTER
     AND pr.ID = pl.PRODUCT_ID
 JOIN
    PRODUCT_GROUP pg
 ON
    pl.PRODUCT_GROUP_ID = pg.ID
    AND pr.PRIMARY_PRODUCT_GROUP_ID = pg.ID
 WHERE
     pu.PRIVILEGE_ID = 24214 -- Free Nutromino Privilege
     AND pu.GRANT_ID = 32825
     AND pu.STATE <> 'CANCELLED'
