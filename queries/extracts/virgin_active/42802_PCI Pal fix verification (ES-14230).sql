-- The extract is extracted from Exerp on 2026-02-08
-- Extract that finds two reported issues : 

Case 1 = PCI-PAL payment with 1% 'change' 

Case 2 = External device CC transaction registered against a cash register with POS payment method 
 SELECT
     c.SHORTNAME                                                        AS "CENTER",
     TO_CHAR(longtodateC(a."TRANSACTION_TIME",c.id),'YYYY-MM-dd HH24:MI') AS "TRANSACTION_TIME",
     a."CASH_REGISTER"                                                    AS "CASH REGISTER",
     a."EMPLOYEE"                                                         AS "EMPLOYEE",
     a."CUSOMTER_ID"                                                      AS "CUSOMTER_ID",
     a."AMOUNT"                                                           AS "TRANSACTION_AMOUNT",
     a."CARD_TYPE"                                                        AS "CARD_TYPE",
     CASE
         WHEN a."CASE_1" =1
         THEN 1
         ELSE 2
     END AS "CASE"
 FROM
     (
         SELECT DISTINCT
             cct.CENTER                                                                                     AS "CCT_CENTER",
             crt.EMPLOYEECENTER||'emp'||crt.EMPLOYEEID                                                      AS "EMPLOYEE",
             cct.center||'-'||cct.id                                                                        AS "CCT_ID",
             crt.CUSTOMERCENTER||'p'||crt.CUSTOMERID                                                        AS "CUSOMTER_ID",
             cct.TRANSTIME                                                                                  AS "TRANSACTION_TIME",
             cr.name                                                                                        AS "CASH_REGISTER",
             cct.AMOUNT                                                                                     AS "AMOUNT",
             CASE 
             WHEN cct.TYPE = 1
             THEN 'VISA'
             WHEN cct.TYPE = 2
             THEN 'MASTERCARD'
             WHEN cct.TYPE = 3
             THEN 'MAESTRO'
             WHEN cct.TYPE = 37
             THEN 'External Device'
             WHEN cct.TYPE = 5
             THEN 'AMERICAN_EXPRESS'
             END AS "CARD_TYPE",
--             DECODE(cct.TYPE,1,'VISA',2,'MASTERCARD',3,'MAESTRO',37,'External Device',5,'AMERICAN_EXPRESS') AS "CARD_TYPE",
             CASE
                 WHEN (crt.AMOUNT*100 = cct.AMOUNT
                         AND cct.amount != 0
                         AND cct.TRANSACTION_ID IS NOT NULL
                         AND ps.STATE = 'COMMITTED')
                 THEN 1
                 ELSE 0
             END AS "CASE_1",
             CASE
                 WHEN cct.TYPE = 37
                     AND cr.CC_PAYMENT_METHOD <>3
                 THEN 1
                 ELSE 0
             END AS "CASE_2"
         FROM
             CREDITCARDTRANSACTIONS cct
         JOIN
             CASHREGISTERTRANSACTIONS crt
         ON
             crt.GLTRANSCENTER = cct.GL_TRANS_CENTER
             AND crt.GLTRANSID = cct.GL_TRANS_ID
             AND crt.GLTRANSSUBID = cct.GL_TRANS_SUBID
         JOIN
             CASHREGISTERS cr
         ON
             cr.CENTER = crt.center
             AND cr.id = crt.id
         LEFT JOIN
             INVOICES inv
         ON
             inv.PAYSESSIONID = crt.PAYSESSIONID
         LEFT JOIN
             SHOPPING_BASKETS sb
         ON
             sb.EMPLOYEE_CENTER = inv.EMPLOYEE_CENTER
             AND sb.EMPLOYEE_ID = inv.EMPLOYEE_ID
             AND sb.MODIFIED = inv.TRANS_TIME
         LEFT JOIN
             PAYMENT_SESSIONS ps
         ON
             ps.SHOPPING_BASKET_ID = sb.ID ) a
 JOIN
     CENTERS c
 ON
     c.ID = a."CCT_CENTER"
 WHERE
     a."TRANSACTION_TIME" > $$earliest_date$$
     AND (
         a."CASE_1" = 1
         OR a."CASE_2" = 1)