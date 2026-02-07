-- This is the version from 2026-02-05
--  
SELECT
    il.CENTER AS "Invoice Center",
    TO_CHAR(TRUNC(longtodate(inv.TRANS_TIME)), 'dd-MM-yyyy') AS SALE_DATE,
    pr.NAME AS "Product",
    il.QUANTITY,
    il.PRODUCT_NORMAL_PRICE,
    il.TOTAL_AMOUNT AS Price,
    p.CENTER || 'p' || p.ID AS "Member ID",
    DECODE(mpr.ID, NULL, 'False', 'True') AS "Has Addon",
    s.start_date AS main_start,
    sa.START_DATE AS add_on_start,
    DECODE(inv.EMPLOYEE_CENTER || 'emp' || inv.EMPLOYEE_ID, '100emp5313', 'yes', 'no') AS "Vending",
    COUNT(*) OVER (PARTITION BY p.CENTER, p.ID, TRUNC(longtodate(inv.TRANS_TIME))) AS "Invoice Lines Count"
FROM
    INVOICELINES il
JOIN
    PERSONS p ON il.PERSON_CENTER = p.CENTER AND il.PERSON_ID = p.ID
JOIN
    INVOICES inv ON inv.CENTER = il.CENTER AND inv.ID = il.ID
JOIN
    SUBSCRIPTIONS s ON s.OWNER_CENTER = p.CENTER AND s.OWNER_ID = p.ID
JOIN
    SUBSCRIPTION_ADDON sa ON sa.SUBSCRIPTION_CENTER = s.CENTER AND sa.SUBSCRIPTION_ID = s.ID AND sa.START_DATE < longtodate(inv.TRANS_TIME) AND sa.CANCELLED = 0 AND sa.ENDING_TIME IS NULL AND (sa.END_DATE > longtodate(inv.TRANS_TIME) OR sa.END_DATE IS NULL)
JOIN
    MASTERPRODUCTREGISTER mpr ON mpr.ID = sa.ADDON_PRODUCT_ID AND mpr.GLOBALID LIKE 'ALL_IN%'
JOIN
    PRODUCTS pr ON pr.CENTER = il.PRODUCTCENTER AND pr.ID = il.PRODUCTID
JOIN
    PRODUCT_AND_PRODUCT_GROUP_LINK ppgl ON ppgl.PRODUCT_CENTER = il.PRODUCTCENTER AND ppgl.PRODUCT_ID = il.PRODUCTID AND ppgl.PRODUCT_GROUP_ID = '5801'
JOIN
    FW.INVOICES inv ON inv.center = il.center AND inv.id = il.ID
WHERE
    il.TOTAL_AMOUNT = 0 AND inv.CENTER IN (:scope) AND inv.TRANS_TIME BETWEEN :from_date AND :end_date + 1000*60*60*24
and p.persontype !=2
