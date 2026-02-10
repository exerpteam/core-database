-- The extract is extracted from Exerp on 2026-02-08
-- https://clublead.atlassian.net/browse/ST-3667
SELECT
    TO_CHAR(longtodateC(it.BOOK_TIME, PRODUCT_CENTER), 'YYYY-MM-DD HH24:MI:SS') AS "Book Time",
    prod.NAME AS "Product Name",
    it.TYPE,
    it.QUANTITY AS "Units sold",
    it.UNIT_VALUE AS "Cost price",
    it.QUANTITY*it.UNIT_VALUE AS "Total Price",
    it.COMENT AS "Comment",
    p.FULLNAME AS "Employee",
    TO_CHAR(longtodateC(it.ENTRY_TIME, PRODUCT_CENTER), 'YYYY-MM-DD HH24:MI:SS') AS "Entry Time"
FROM
    INVENTORY_TRANS it
JOIN
    INVENTORY i
ON
    it.INVENTORY = i.ID 
LEFT JOIN
    PRODUCTS prod
ON
    prod.CENTER = it.PRODUCT_CENTER
    AND prod.ID = it.PRODUCT_ID
LEFT JOIN 
    EMPLOYEES emp
ON    
    emp.CENTER = it.EMPLOYEE_CENTER
    AND emp.ID = it.EMPLOYEE_ID
LEFT JOIN
    PERSONS p
ON
    p.CENTER = emp.PERSONCENTER
    AND p.ID = emp.PERSONID    
WHERE 
   it.ENTRY_TIME >= :FROM_DATE
   AND it.ENTRY_TIME <= :TO_DATE + 24*3600*1000
   AND it.PRODUCT_CENTER in (:Scope)