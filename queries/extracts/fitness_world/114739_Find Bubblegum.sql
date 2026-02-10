-- The extract is extracted from Exerp on 2026-02-08
--  
SELECT
  inv.CENTER,
  prod.GLOBALID,
  prod.NAME,
  pg.NAME,
  TO_TIMESTAMP(inv.TRANS_TIME / 1000) AS TRANS_TIME,
  pemp.FIRSTNAME || ' ' || pemp.LASTNAME AS emp_name,
  emp.CENTER || 'emp' || emp.ID AS emp_id,
  pemp.CENTER || 'p' || pemp.ID AS emp_pid,
  p.CENTER || 'p' || p.id AS pid,
  p.FIRSTNAME || ' ' || p.LASTNAME AS cust_name,
  CASE WHEN art.CENTER IS NOT NULL THEN 1 ELSE 0 END AS sold_on_account
FROM
  INVOICELINES invl
JOIN INVOICES inv
  ON inv.CENTER = invl.CENTER AND inv.id = invl.id
JOIN PRODUCTS prod
  ON prod.CENTER = invl.PRODUCTCENTER AND prod.id = invl.PRODUCTID
JOIN PRODUCT_GROUP pg
  ON pg.ID = prod.PRIMARY_PRODUCT_GROUP_ID
JOIN EMPLOYEES emp
  ON emp.CENTER = inv.EMPLOYEE_CENTER AND emp.ID = inv.EMPLOYEE_ID
JOIN PERSONS pemp
  ON pemp.CENTER = emp.PERSONCENTER AND pemp.ID = emp.PERSONID
LEFT JOIN PERSONS p
  ON p.CENTER = inv.PAYER_CENTER AND p.ID = inv.PAYER_ID
LEFT JOIN AR_TRANS art
  ON art.REF_TYPE = 'INVOICE'
     AND art.REF_CENTER = inv.CENTER
     AND art.REF_ID = inv.ID
WHERE
  inv.CENTER IN (:scope)
  AND prod.PTYPE NOT IN (5, 6, 7, 10, 12)
  AND inv.TRANS_TIME BETWEEN :startDate AND :endDate
  AND NOT (inv.EMPLOYEE_CENTER = 100 AND inv.EMPLOYEE_ID = 1)
  AND prod.GLOBALID LIKE '%BUBBLE%';
