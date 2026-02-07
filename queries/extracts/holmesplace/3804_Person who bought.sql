SELECT
 invoice.CENTER || 'inv' || invoice.ID AS INVOICEID,
 salesPersonCenter.NAME AS SALESPERSON_CENTER,
 salesPerson.CENTER || 'p' || salesPerson.ID AS SALESPERSON_ID,
 salesPerson.FIRSTNAME || ' ' || salesPerson.LASTNAME AS SALESPERSON,
 invoiceCenter.NAME AS SALES_CENTER,
 TO_DATE('01011970', 'DDMMYYYY') + invoice.TRANS_TIME/(24*3600*1000) + 1/24 AS SALES_DAY,
 customer.CENTER || 'p' || customer.ID AS CUSTOMER_ID,
 customer.FIRSTNAME || ' ' || customer.LASTNAME AS CUSTOMER,
 DECODE (customer.persontype, 0, 'privat', 1, 'Student', 2, 'staff', 3, 'Friend', 4, 'Corporate', 5, 'One-Man Corp', 6, 'Family', 7, 'Senior') AS CUSTOMERTYPE,
 round(((sysdate - customer.birthdate)/360),0) as age,
 prod.NAME AS PRODUCT,
prodg.name,
 invoiceLine."QUANTITY",
 invoiceLine."PRODUCT_NORMAL_PRICE",
 invoiceLine."TOTAL_AMOUNT"
 FROM
INVOICES invoice
 JOIN INVOICELINES invoiceLine
 ON
 invoice.CENTER=invoiceLine.CENTER
 AND invoice.ID=invoiceLine.ID
 JOIN PRODUCTS prod
 ON
 invoiceLine.PRODUCTCENTER=prod.CENTER
 AND invoiceLine.PRODUCTID=prod.ID
 JOIN EMPLOYEES employee
 ON
 invoice.EMPLOYEE_CENTER=employee.CENTER
 AND invoice.EMPLOYEE_ID=employee.ID
 JOIN product_group prodg
 ON
prodg.id = prod.PRIMARY_PRODUCT_GROUP_ID 

JOIN PERSONS salesPerson
 ON
 employee.PERSONCENTER=salesPerson.CENTER
 AND employee.PERSONID=salesPerson.ID
 JOIN CENTERS salesPersonCenter
 ON
 salesPerson.CENTER=salesPersonCenter.ID
 JOIN CENTERS invoiceCenter
 ON
 invoice.CENTER=invoiceCenter.ID
 LEFT JOIN AR_TRANS arTrans
 ON
 invoice.CENTER = arTrans.REF_CENTER
 AND invoice.ID = arTrans.REF_ID
 AND arTrans.REF_TYPE = 'INVOICE'
 LEFT JOIN ACCOUNT_RECEIVABLES AR
 ON
 AR.CENTER = arTrans.CENTER
 AND AR.ID = arTrans.ID
 LEFT JOIN PERSONS customer
 ON
 invoiceLine.person_CENTER=customer.CENTER
 AND invoiceLine.person_ID=customer.ID
 WHERE
 invoice.CENTER in (:Scope)
 and invoice.TRANS_TIME>= :FromDate
 and invoice.TRANS_TIME<:ToDateExclusive and
 prod.NAME =:ProdName