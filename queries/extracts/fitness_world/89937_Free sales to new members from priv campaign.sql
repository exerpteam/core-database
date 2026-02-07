-- This is the version from 2026-02-05
--  
SELECT
    il.CENTER "Invoice Center",
    TO_CHAR(TRUNC(longtodate(inv.TRANS_TIME)),'dd-MM-yyyy')    SALE_DATE,
    pr.NAME                                                 AS "Product",
    il.QUANTITY,
    il.PRODUCT_NORMAL_PRICE,
    il.TOTAL_AMOUNT                    Price ,
    p.CENTER||'p'|| p.ID               AS "Member ID",
        s.start_date                       main_start,
    case inv.EMPLOYEE_CENTER||'emp'||inv.EMPLOYEE_ID when '100emp5313' then 'yes' else 'no' end as "Vending"
FROM
    INVOICELINES il
JOIN
    PERSONS p
ON
    il.PERSON_CENTER = p.CENTER
    AND il.PERSON_ID = p.ID
JOIN
    INVOICES inv
ON
    inv.CENTER = il.CENTER
    AND inv.ID = il.ID
JOIN
    SUBSCRIPTIONS s
ON
    s.OWNER_CENTER = p.CENTER
    AND s.OWNER_ID = p.ID

JOIN
    PRODUCTS pr
ON
    pr.CENTER = il.PRODUCTCENTER
    AND pr.ID = il.PRODUCTID
JOIN
    PRODUCT_AND_PRODUCT_GROUP_LINK ppgl
ON
    ppgl.PRODUCT_CENTER = il.PRODUCTCENTER
    AND ppgl.PRODUCT_ID = il.PRODUCTID
    AND ppgl.PRODUCT_GROUP_ID = '5801'
WHERE
    il.TOTAL_AMOUNT = 0
    AND inv.CENTER IN (:scope)
    AND inv.TRANS_TIME BETWEEN :from_date AND :end_date +1000*60*60*24 
and s.CREATION_TIME BETWEEN :SUb_start_FROM_DATE AND :Sub_start_TO_DATE
