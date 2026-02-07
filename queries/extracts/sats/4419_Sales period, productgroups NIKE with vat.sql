SELECT
    invoice.CENTER || 'inv' || invoice.ID                                      
                                                                  AS INVOICEID,
    salesPersonCenter.NAME                                                     
                                                                  AS
SALESPERSON_CENTER,
    salesPerson.CENTER || 'p' || salesPerson.ID                                
                                                                  AS
SALESPERSON_ID,
    salesPerson.FIRSTNAME || ' ' || salesPerson.LASTNAME                       
                                                                  AS
SALESPERSON,
    invoiceCenter.NAME                                                         
                                                                  AS
SALES_CENTER,
    TO_DATE('01011970', 'DDMMYYYY') + invoice.TRANS_TIME/(24*3600*1000) + 1/24 
                                                                  AS SALES_DAY,
    customer.CENTER || 'p' || customer.ID                                      
                                                                  AS
CUSTOMER_ID,
    customer.FIRSTNAME || ' ' || customer.LASTNAME                             
                                                                  AS CUSTOMER,
    DECODE (customer.persontype, 0, 'privat', 1, 'Student', 2, 'staff', 3,
'Friend', 4, 'Corporate', 5, 'One-Man Corp', 6, 'Family', 7, 'Senior') AS
CUSTOMERTYPE,
    prod.NAME                                                                  
                                                                  AS PRODUCT,
prodg.name,
    invoiceLine."QUANTITY",
    invoiceLine."PRODUCT_NORMAL_PRICE",
    invoiceLine."TOTAL_AMOUNT",
actrans.amount as "VAT_Amount",
prod.EXTERNAL_ID
FROM
    eclub2.INVOICES invoice
JOIN eclub2.INVOICELINES invoiceLine
ON
    invoice.CENTER=invoiceLine.CENTER
    AND invoice.ID=invoiceLine.ID
JOIN eclub2.PRODUCTS prod
ON
    invoiceLine.PRODUCTCENTER=prod.CENTER
    AND invoiceLine.PRODUCTID=prod.ID
JOIN eclub2.EMPLOYEES employee
ON
    invoice.EMPLOYEE_CENTER=employee.CENTER
    AND invoice.EMPLOYEE_ID=employee.ID
JOIN eclub2.productgroups prodg
ON
    prodg.CENTER=prod.productgroup_CENTER
    AND prodg.ID=prod.Productgroup_ID
JOIN eclub2.PERSONS salesPerson
ON
    employee.PERSONCENTER=salesPerson.CENTER
    AND employee.PERSONID=salesPerson.ID
JOIN eclub2.CENTERS salesPersonCenter
ON
    salesPerson.CENTER=salesPersonCenter.ID
JOIN eclub2.CENTERS invoiceCenter
ON
    invoice.CENTER=invoiceCenter.ID
LEFT JOIN eclub2.AR_TRANS arTrans
ON
    invoice.CENTER = arTrans.REF_CENTER
    AND invoice.ID = arTrans.REF_ID
    AND arTrans.REF_TYPE = 'INVOICE'
LEFT JOIN eclub2.account_trans acTrans
ON
invoiceline.VAT_ACC_TRANS_CENTER = acTrans.CENTER
    AND invoiceline.VAT_ACC_TRANS_ID = acTrans.ID
    AND invoiceline.VAT_ACC_TRANS_SUBID = acTrans.SUBID
LEFT JOIN eclub2.ACCOUNT_RECEIVABLES AR
ON
    AR.CENTER = arTrans.CENTER
    AND AR.ID = arTrans.ID
LEFT JOIN eclub2.PERSONS customer
ON
    AR.CUSTOMERCENTER=customer.CENTER
    AND AR.CUSTOMERID=customer.ID
WHERE
    invoice.CENTER BETWEEN
:FromCenter AND
:ToCenter
    and invoice.TRANS_TIME>= :Fromdate
    and invoice.TRANS_TIME<:ToDate
and
  prodg.globalid in ('NIKE_RUNNING','NIKE_SHOES','NIKE_MEN_TRAINING','NIKE_WOMEN_TRAINING',
'NIKE_NEW_SPORT_INSPIRED','NIKE_ALL_OTHER')
