SELECT
cn.center || 'cred' || cn.id as CredInvoice,
cn.invoice_center || 'inv' || cn.invoice_id                                                                                                      AS INVOICEID,
prod.NAME,
cl.quantity,
cl.total_amount,
cn.coment,
cn.text,
salesPerson.FIRSTNAME || ' ' || salesPerson.LASTNAME                                                                                          AS SALESPERSON,
cl.canceltype,
cl.reason

FROM
    eclub2.credit_notes cn

join eclub2.credit_note_lines cl
on cn.center =cl.center and
cn.id= cl.id
JOIN eclub2.PRODUCTS prod
ON
   cl.PRODUCTCENTER=prod.CENTER
    AND cl.PRODUCTID=prod.ID
JOIN eclub2.EMPLOYEES employee
ON
    cn.EMPLOYEECENTER=employee.CENTER
    AND cn.EMPLOYEEID=employee.ID
JOIN eclub2.PERSONS salesPerson
ON
    employee.PERSONCENTER=salesPerson.CENTER
    AND employee.PERSONID=salesPerson.ID
JOIN eclub2.CENTERS salesPersonCenter
ON
    salesPerson.CENTER=salesPersonCenter.ID


WHERE
cn.CENTER BETWEEN :FromCenter AND :ToCenter and
cn.text <>'_eClub_SUBSCRIPTION_CHANGED'
 and cn.TRANS_TIME>= :From_date
    and cn.TRANS_TIME<:To_date_(exclusive)
