-- The extract is extracted from Exerp on 2026-02-08
--  
WITH
    CTE_INVOICES AS MATERIALIZED (
        SELECT
            *
        FROM
            INVOICES inv
        WHERE
            inv.CENTER IN (:scope)
            AND inv.TRANS_TIME BETWEEN :startDate AND :endDate
    )
SELECT DISTINCT
    inv.CENTER,
    prod.GLOBALID,
    prod.NAME AS Product_Name,
    prod.price AS Product_Price,
    pg.NAME AS Product_Group,
    longToDate(inv.TRANS_TIME) AS TRANS_TIME,
    pemp.FIRSTNAME || ' ' || pemp.LASTNAME AS Employee_Name,
    emp.CENTER || 'emp' || emp.ID AS Employee_ID,
    pemp.CENTER || 'p' || pemp.ID AS Employee_PID,
    p.CENTER || 'p' || p.ID AS Member_ID,
    p.fullname AS Member_Name,
    p.sex AS Member_Sex,
    EXTRACT(YEAR FROM age(p.BIRTHDATE)) AS Age,
    cd.CODE AS Campaign_Code
FROM
    INVOICELINES invl
JOIN 
    CTE_INVOICES inv
    ON inv.CENTER = invl.CENTER
    AND inv.ID = invl.ID
JOIN 
    PRODUCTS prod
    ON prod.CENTER = invl.PRODUCTCENTER
    AND prod.ID = invl.PRODUCTID
JOIN 
    PRODUCT_GROUP pg
    ON pg.ID = prod.PRIMARY_PRODUCT_GROUP_ID
JOIN 
    EMPLOYEES emp
    ON emp.CENTER = inv.EMPLOYEE_CENTER
    AND emp.ID = inv.EMPLOYEE_ID
JOIN 
    PERSONS pemp
    ON pemp.CENTER = emp.PERSONCENTER
    AND pemp.ID = emp.PERSONID
LEFT JOIN 
    PERSONS p
    ON p.CENTER = inv.PAYER_CENTER
    AND p.ID = inv.PAYER_ID
LEFT JOIN 
    AR_TRANS art
    ON art.REF_TYPE = 'INVOICE'
    AND art.REF_CENTER = inv.CENTER
    AND art.REF_ID = inv.ID
JOIN 
    PERSON_EXT_ATTRS mobile
    ON mobile.personcenter = p.center
    AND mobile.personid = p.id
-- Join CAMPAIGN_CODES table to capture campaign codes
JOIN 
    PRIVILEGE_USAGES pu
    ON pu.PERSON_CENTER = p.CENTER
    AND pu.PERSON_ID = p.ID
JOIN 
    CAMPAIGN_CODES cd
    ON cd.ID = pu.CAMPAIGN_CODE_ID -- Ensure the campaign code is linked
WHERE
    prod.PTYPE NOT IN (5, 10, 12, 6, 7) -- Exclude certain product types (adjust if needed)
    AND prod.GLOBALID LIKE 'PT%' -- Only PT products
    AND invl.PRODUCTID IS NOT NULL -- Ensure the product exists in the invoiceline
    -- Ensure campaign code is used for these products
    AND cd.CODE IS NOT NULL -- Ensure a campaign code has been used
    AND TO_CHAR(longtodate(pu.USE_TIME), 'DD-MM-YYYY') = TO_CHAR(longtodate(inv.TRANS_TIME), 'DD-MM-YYYY') -- Match campaign code usage date with invoice date
ORDER BY
    TRANS_TIME;
