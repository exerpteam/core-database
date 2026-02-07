select invoice.CENTER || 'inv' || invoice.ID as INVOICEID, 
salesPersonCenter.NAME as SALESPERSON_CENTER,
salesPerson.CENTER || 'p' || salesPerson.ID as SALESPERSON_ID, 
salesPerson.FIRSTNAME || ' ' || salesPerson.LASTNAME as SALESPERSON, 
invoiceCenter.NAME as SALES_CENTER, 
TO_DATE('01011970', 'DDMMYYYY') + invoice.TRANS_TIME/(24*3600*1000) + 1/24 as SALES_DAY,
customer.CENTER || 'p' || customer.ID as CUSTOMER_ID,  customer.FIRSTNAME || ' ' || customer.LASTNAME as CUSTOMER,
decode (customer.persontype, 0, 'privat', 1, 'Student', 2, 'staff', 3, 'Friend', 4, 'Corporate', 5, 'One-Man Corp', 6, 'Family', 7, 'Senior') as CUSTOMERTYPE,
prod.NAME as PRODUCT, 
invoiceLine."QUANTITY", invoiceLine."PRODUCT_NORMAL_PRICE", invoiceLine."TOTAL_AMOUNT", s.start_date, s.state
from eclub2.INVOICES invoice
join eclub2.INVOICELINES invoiceLine on invoice.CENTER=invoiceLine.CENTER and invoice.ID=invoiceLine.ID 
join eclub2.PRODUCTS prod on invoiceLine.PRODUCTCENTER=prod.CENTER and invoiceLine.PRODUCTID=prod.ID 
join eclub2.EMPLOYEES employee on invoice.EMPLOYEE_CENTER=employee.CENTER and invoice.EMPLOYEE_ID=employee.ID
join eclub2.PERSONS salesPerson on employee.PERSONCENTER=salesPerson.CENTER and employee.PERSONID=salesPerson.ID
join eclub2.CENTERS salesPersonCenter on salesPerson.CENTER=salesPersonCenter.ID
join eclub2.CENTERS invoiceCenter on invoice.CENTER=invoiceCenter.ID
LEFT join eclub2.AR_TRANS arTrans on invoice.CENTER = arTrans.INVOICE_CENTER and invoice.ID = arTrans.INVOICE_ID
LEFT join eclub2.ACCOUNT_RECEIVABLES  AR on AR.CENTER = arTrans.CENTER and AR.ID = arTrans.ID
LEFT join eclub2.PERSONS customer on AR.CUSTOMERCENTER=customer.CENTER and AR.CUSTOMERID=customer.ID
Left join eclub2.subscriptions s on customer.id = s.owner_id and AR.customer.center =s.owner_center
where 
invoice.CENTER BETWEEN :FromCenter AND :ToCenter
and invoice.TRANS_TIME>= :From_date
and invoice.TRANS_TIME<:To_date_(exclusive) and
prod.NAME = :extern
and s.state =2 or s.state=8