-- The extract is extracted from Exerp on 2026-02-08
-- Ticket 44953
WITH
    params AS materialized
    (
        SELECT
            (:from_date)::bigint                 AS from_date,
            ((:end_date)::bigint +1000*60*60*24) AS end_date
    )
    ,
    cte_invoices AS materialized
    (
        SELECT
            inv.CENTER,
            inv.ID,
            inv.trans_time,
            inv.EMPLOYEE_CENTER,
            inv.EMPLOYEE_ID
        FROM
            INVOICES inv
        CROSS JOIN
            params
        WHERE
            inv.CENTER IN (:scope)
        AND inv.TRANS_TIME BETWEEN from_date AND end_date
    )
    ,
    cte_invoicelines AS materialized
    (
        SELECT
            il.center,
            il.id,
            il.PRODUCTCENTER,
            il.PRODUCTid,
            il.PERSON_CENTER,
            il.PERSON_id,
            il.QUANTITY,
            il.PRODUCT_NORMAL_PRICE,
            il.TOTAL_AMOUNT,
            inv.trans_time,
            inv.EMPLOYEE_CENTER,
            inv.EMPLOYEE_ID
        FROM
            cte_invoices inv
        JOIN
            INVOICE_LINES_mt il
        ON
            inv.CENTER = il.CENTER
        AND inv.ID = il.ID
        WHERE
            il.TOTAL_AMOUNT = 0
    )
SELECT
    il.CENTER "Invoice Center",
    TO_CHAR(TRUNC(longtodate(il.TRANS_TIME)),'dd-MM-yyyy')    SALE_DATE,
    pr.NAME                                                AS "Product",
    il.QUANTITY,
    il.PRODUCT_NORMAL_PRICE,
    il.TOTAL_AMOUNT      AS Price ,
    p.CENTER||'p'|| p.ID AS "Member ID",
    CASE
        WHEN mpr.ID IS NULL
        THEN 'False'
        ELSE 'True'
    END           AS "Has Addon",
    s.start_date  main_start,
    sa.START_DATE add_on_start,
    CASE il.EMPLOYEE_CENTER||'emp'||il.EMPLOYEE_ID
        WHEN '100emp5313'
        THEN 'yes'
        ELSE 'no'
    END AS "Vending"
FROM
    cte_invoicelines il
JOIN
    PERSONS p
ON
    il.PERSON_CENTER = p.CENTER
AND il.PERSON_ID = p.ID
JOIN
    SUBSCRIPTIONS s
ON
    s.OWNER_CENTER = p.CENTER
AND s.OWNER_ID = p.ID
JOIN
    SUBSCRIPTION_ADDON sa
ON
    sa.SUBSCRIPTION_CENTER = s.CENTER
AND sa.SUBSCRIPTION_ID = s.ID
JOIN
    MASTERPRODUCTREGISTER mpr
ON
    mpr.ID = sa.ADDON_PRODUCT_ID
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
WHERE
    sa.START_DATE < longtodate(il.TRANS_TIME)
AND sa.CANCELLED = 0
AND sa.ENDING_TIME IS NULL
AND (
        sa.END_DATE > longtodate(il.TRANS_TIME)
    OR  sa.END_DATE IS NULL)
AND mpr.GLOBALID LIKE 'ALL_IN%'
AND ppgl.PRODUCT_GROUP_ID = '5801'