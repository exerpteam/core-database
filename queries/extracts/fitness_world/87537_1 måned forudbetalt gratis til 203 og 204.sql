-- The extract is extracted from Exerp on 2026-02-08
--  
SELECT
inv.CENTER,
prod.GLOBALID,
prod.NAME,
pg.NAME,
longToDate(inv.TRANS_TIME) TRANS_TIME,
pemp.FIRSTNAME || ' ' || pemp.LASTNAME emp_name,
emp.CENTER || 'emp' || emp.ID emp_id,
pemp.CENTER || 'p' || pemp.ID emp_pid,
p.CENTER || 'p' || p.id pid,
p.FIRSTNAME || ' ' || p.LASTNAME cust_name,
nvl2(art.CENTER,1,0) sold_on_account
FROM
FW.INVOICELINES invl
JOIN FW.INVOICES inv
ON
inv.CENTER = invl.CENTER
AND inv.id = invl.id
JOIN FW.PRODUCTS prod
ON
prod.CENTER = invl.PRODUCTCENTER
AND prod.id = invl.PRODUCTID
JOIN FW.PRODUCT_GROUP pg
ON
pg.ID = prod.PRIMARY_PRODUCT_GROUP_ID
JOIN FW.EMPLOYEES emp
ON
emp.CENTER = inv.EMPLOYEE_CENTER
AND emp.ID = inv.EMPLOYEE_ID
JOIN FW.PERSONS pemp
ON
pemp.CENTER = emp.PERSONCENTER
AND pemp.ID = emp.PERSONID
LEFT JOIN FW.PERSONS p
ON
p.CENTER = inv.PAYER_CENTER
AND p.ID = inv.PAYER_ID
LEFT JOIN FW.AR_TRANS art
ON
art.REF_TYPE = 'INVOICE'
AND art.REF_CENTER = inv.CENTER
AND art.REF_ID = inv.ID
WHERE
p.CENTER in (203,204,100)
AND prod.GLOBALID = 'CREATION_VOUCHER_1M'
and inv.trans_time > :time
