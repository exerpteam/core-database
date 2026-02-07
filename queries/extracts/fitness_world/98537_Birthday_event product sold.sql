-- This is the version from 2026-02-05
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
CASE WHEN art.CENTER IS NOT NULL THEN 1 ELSE 0 END sold_on_account
FROM
INVOICELINES invl
JOIN INVOICES inv
ON
inv.CENTER = invl.CENTER
AND inv.id = invl.id
JOIN PRODUCTS prod
ON
prod.CENTER = invl.PRODUCTCENTER
AND prod.id = invl.PRODUCTID
JOIN PRODUCT_GROUP pg
ON
pg.ID = prod.PRIMARY_PRODUCT_GROUP_ID
JOIN EMPLOYEES emp
ON
emp.CENTER = inv.EMPLOYEE_CENTER
AND emp.ID = inv.EMPLOYEE_ID
JOIN PERSONS pemp
ON
pemp.CENTER = emp.PERSONCENTER
AND pemp.ID = emp.PERSONID
LEFT JOIN PERSONS p
ON
p.CENTER = inv.PAYER_CENTER
AND p.ID = inv.PAYER_ID
LEFT JOIN AR_TRANS art
ON
art.REF_TYPE = 'INVOICE'
AND art.REF_CENTER = inv.CENTER
AND art.REF_ID = inv.ID
WHERE
inv.CENTER IN (:scope)
AND inv.TRANS_TIME between :startDate and :endDate
AND prod.GLOBALID = 'BIRTHDAY_EVENT'
