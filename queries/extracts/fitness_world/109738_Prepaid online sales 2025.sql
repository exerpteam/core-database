-- This is the version from 2026-02-05
--  
SELECT 
    inv.CENTER,
    prod.GLOBALID,
    prod.NAME,
    pg.NAME AS PRODUCT_GROUP_NAME,
    longToDate(inv.TRANS_TIME) AS TRANS_TIME,
    pemp.FIRSTNAME || ' ' || pemp.LASTNAME AS emp_name,
    emp.CENTER || 'emp' || emp.ID AS emp_id,
    pemp.CENTER || 'p' || pemp.ID AS emp_pid,
    p.CENTER || 'p' || p.ID AS pid,
    p.FIRSTNAME || ' ' || p.LASTNAME AS cust_name
FROM FW.INVOICELINES invl
JOIN FW.INVOICES inv 
    ON inv.CENTER = invl.CENTER 
    AND inv.ID = invl.ID
    AND inv.trans_time BETWEEN :date_from AND :date_to  -- Filter early
JOIN FW.PRODUCTS prod 
    ON prod.CENTER = invl.PRODUCTCENTER 
    AND prod.ID = invl.PRODUCTID 
    AND prod.PRIMARY_PRODUCT_GROUP_ID = 52201  -- Filter early
JOIN FW.PRODUCT_GROUP pg 
    ON pg.ID = prod.PRIMARY_PRODUCT_GROUP_ID
JOIN FW.EMPLOYEES emp 
    ON emp.CENTER = inv.EMPLOYEE_CENTER 
    AND emp.ID = inv.EMPLOYEE_ID
JOIN FW.PERSONS pemp 
    ON pemp.CENTER = emp.PERSONCENTER 
    AND pemp.ID = emp.PERSONID 
LEFT JOIN FW.PERSONS p 
    ON p.CENTER = inv.PAYER_CENTER 
    AND p.ID = inv.PAYER_ID
WHERE p.CENTER IN (:scope);
