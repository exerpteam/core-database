 SELECT DISTINCT
     cct.CENTER                                                                                     AS "CCT_CENTER",
 c.name as "Club name",
     crt.EMPLOYEECENTER||'emp'||crt.EMPLOYEEID                                                      AS "EMPLOYEE",
 staffp.fullname as "Employee name",
     cct.center||'-'||cct.id                                                                        AS "CCT_ID",
     cct.ORDER_ID                                                                                   AS "ORDER_ID",
     crt.CUSTOMERCENTER||'p'||crt.CUSTOMERID                                                        AS "CUSOMTER_ID",
     longtodate(cct.TRANSTIME)                                                                      AS "TRANSACTION_TIME",
     cr.name                                                                                        AS "CASH_REGISTER",
     cct.AMOUNT                                                                                     AS "AMOUNT",
     CASE cct.TYPE WHEN 1 THEN 'VISA' WHEN 2 THEN 'MASTERCARD' WHEN 3 THEN 'MAESTRO' WHEN 37 THEN 'External Device' WHEN 5 THEN 'AMERICAN_EXPRESS' END AS "CARD_TYPE"
 FROM
     CREDITCARDTRANSACTIONS cct
 JOIN
     CASHREGISTERTRANSACTIONS crt
 ON
     crt.GLTRANSCENTER = cct.GL_TRANS_CENTER
     AND crt.GLTRANSID = cct.GL_TRANS_ID
     AND crt.GLTRANSSUBID = cct.GL_TRANS_SUBID
 JOIN
     persons p
 ON
     p.center = crt.CUSTOMERCENTER
     AND p.id = crt.CUSTOMERID
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
     ps.SHOPPING_BASKET_ID = sb.ID
 left join centers c
 on
 cct.CENTER = c.id
 LEFT JOIN employees staff
 ON
     crt.EMPLOYEECENTER = staff.center
     AND crt .EMPLOYEEID = staff.id
 LEFT JOIN persons staffp
 ON
     staff.personcenter = staffp.center
     AND staff.personid = staffp.id
 WHERE
     cct.ORDER_ID in (:orderid)
