-- The extract is extracted from Exerp on 2026-02-08
--  
WITH
    CTE_INVOICES AS MATERIALIZED
    (   SELECT
            *
        FROM
            INVOICES inv
        WHERE
            inv.CENTER IN(:scope)
            AND inv.TRANS_TIME BETWEEN :from_date AND :end_date +1000 * 60 * 60 * 24
    )
    ,
    CTE_INVOICELINES AS MATERIALIZED
    (   SELECT
            *
        FROM
            INVOICELINES il
        WHERE
            il.TOTAL_AMOUNT = 0
            AND il.QUANTITY > 14
    )
SELECT
    il.CENTER "Invoice Center",
    TO_CHAR(TRUNC(longtodate(inv.TRANS_TIME)), 'dd-MM-yyyy') SALE_DATE,
    pr.NAME                                                  AS "Product",
    il.QUANTITY,
    il.PRODUCT_NORMAL_PRICE,
    il.TOTAL_AMOUNT      Price,
    p.CENTER||'p'|| p.ID AS "Member ID",
    CASE
        WHEN mpr.ID IS NULL THEN 'False'
        ELSE 'True'
    END           AS "Has Addon",
    s.start_date  main_start,
    sa.START_DATE add_on_start,
    CASE inv.EMPLOYEE_CENTER||'emp'||inv.EMPLOYEE_ID
        WHEN '100emp5313' THEN 'yes'
        ELSE 'no'
    END AS "Vending"
FROM
    CTE_INVOICELINES il
JOIN
    PERSONS p
    ON  il.PERSON_CENTER = p.CENTER
        AND il.PERSON_ID = p.ID
JOIN
    CTE_INVOICES inv
    ON  inv.CENTER = il.CENTER
        AND inv.ID = il.ID
JOIN
    SUBSCRIPTIONS s
    ON  s.OWNER_CENTER = p.CENTER
        AND s.OWNER_ID = p.ID
JOIN
    SUBSCRIPTION_ADDON sa
    ON  sa.SUBSCRIPTION_CENTER = s.CENTER
        AND sa.SUBSCRIPTION_ID = s.ID
JOIN
    MASTERPRODUCTREGISTER mpr
    ON  mpr.ID = sa.ADDON_PRODUCT_ID
JOIN
    PRODUCTS pr
    ON  pr.CENTER = il.PRODUCTCENTER
        AND pr.ID = il.PRODUCTID
JOIN
    PRODUCT_AND_PRODUCT_GROUP_LINK ppgl
    ON  ppgl.PRODUCT_CENTER = il.PRODUCTCENTER
        AND ppgl.PRODUCT_ID = il.PRODUCTID
WHERE
    sa.START_DATE < longtodate(inv.TRANS_TIME)
    AND sa.CANCELLED = 0
    AND sa.ENDING_TIME IS NULL
    AND
    (
        sa.END_DATE > longtodate(inv.TRANS_TIME)
        OR sa.END_DATE IS NULL)
    AND ppgl.PRODUCT_GROUP_ID = '5801'
    AND mpr.GLOBALID IN('ALL_IN',
                        'ALL_IN__FØDSELSDAG_',
                        'ALL_IN__PERSONALE_')