-- The extract is extracted from Exerp on 2026-02-08
--  
 SELECT
     "Invoice ID",
     "Transaction Time",
     FULLNAME,
     "MemberID",
  "ExternalId",
     "Sales Employee",
     "Sales Employee ID",
     "Product Name",
     "Sales in SEK",
     "Quantity",
     "Is credited",
     "Credited Amount",
     CASE WHEN MAX(INSTALLMENT_PLAN_ID) IS NULL THEN 'No' ELSE 'Yes' END AS "Installment Plan"
 FROM
     (
         SELECT
             inv.CENTER||'inv'|| inv.ID AS "Invoice ID",
             longtodate(inv.TRANS_TIME) AS "Transaction Time",
             p.FULLNAME,
             p.CENTER||'p'||p.ID                         AS "MemberID",
 p.external_id "ExternalId",
             staff.FULLNAME                              AS "Sales Employee",
             inv.EMPLOYEE_CENTER||'emp'||inv.EMPLOYEE_ID AS "Sales Employee ID",
             pr.NAME as "Product Name",
             il.TOTAL_AMOUNT                         AS "Sales in SEK",
             il.QUANTITY                             AS "Quantity",
             CASE  WHEN cnl.center IS NULL THEN NULL ELSE 'Credited' END AS "Is credited",
             CASE
                 WHEN cnl.center IS NOT NULL
                 THEN il.TOTAL_AMOUNT*-1
             END AS "Credited Amount",
             crt.INSTALLMENT_PLAN_ID
         FROM
             INVOICES inv
         JOIN
             (
                 SELECT
                     il.center,
                     il.ID,
                     il.SUBID,
                     il.PRODUCTCENTER,
                     il.PRODUCTID,
                     SUM(il.TOTAL_AMOUNT) AS TOTAL_AMOUNT,
                     SUM(il.QUANTITY)     AS QUANTITY
                 FROM
                     INVOICELINES il
                 JOIN
                     PRODUCTS pr
                 ON
                     il.PRODUCTCENTER = pr.CENTER
                     AND il.PRODUCTID = pr.ID
                 WHERE
                     pr.PTYPE =4
                 GROUP BY
                     il.center,
                     il.ID,
                     il.SUBID,
                     il.PRODUCTCENTER,
                     il.PRODUCTID) il
         ON
             inv.CENTER = il.CENTER
             AND inv.ID = il.ID
         JOIN
             PRODUCTS pr
         ON
             il.PRODUCTCENTER = pr.CENTER
             AND il.PRODUCTID = pr.ID
         JOIN
             PERSONS p
         ON
             p.CENTER = inv.PAYER_CENTER
             AND p.ID = inv.PAYER_ID
         JOIN
             EMPLOYEES emp
         ON
             emp.CENTER = inv.EMPLOYEE_CENTER
             AND emp.id=inv.EMPLOYEE_ID
         JOIN
             PERSONS staff
         ON
             staff.CENTER= emp.PERSONCENTER
             AND staff.ID = emp.PERSONID
         LEFT JOIN
             CREDIT_NOTE_LINES cnl
         ON
             cnl.INVOICELINE_CENTER = il.CENTER
             AND cnl.INVOICELINE_ID = il.ID
             AND cnl.INVOICELINE_SUBID = il.SUBID
         LEFT JOIN
             CASHREGISTERTRANSACTIONS crt
         ON
             inv.PAYSESSIONID = crt.PAYSESSIONID
         LEFT JOIN
             INSTALLMENT_PLANS insp
         ON
             insp.ID = crt.INSTALLMENT_PLAN_ID
         WHERE
 inv.CENTER IN($$scope$$)
         AND inv.TRANS_TIME BETWEEN $$startdate$$ AND $$enddate$$ + 1000*60*60*24)  t1
 GROUP BY
     "Invoice ID",
     "Transaction Time",
     FULLNAME,
     "MemberID",
  "ExternalId",
     "Sales Employee",
     "Sales Employee ID",
         "Product Name",
     "Sales in SEK",
     "Quantity",
     "Is credited",
     "Credited Amount"
