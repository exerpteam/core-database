-- The extract is extracted from Exerp on 2026-02-08
--  
SELECT
    il.PERSON_CENTER,
    il.PERSON_ID,
    cc.ID                              AS "Clip Card ID",
    c.NAME                             AS "Sold In",
    pr.NAME                            AS "Product Name",
    longtodate(inv.TRANS_TIME) AS "Sales Time",
    ipc.NAME                           AS "Instalment Plan",
    ip.INSTALLEMENTS_COUNT,
    ROUND(IL.TOTAL_AMOUNT/ip.INSTALLEMENTS_COUNT, 2) AS Amount_per_Instalment,
    il.TOTAL_AMOUNT
FROM
    INVOICELINES il
JOIN
    PRODUCTS pr
ON
    pr.center = il.PRODUCTCENTER
    AND pr.ID = il.PRODUCTID
    AND pr.PTYPE = 4
    --JOIN
    --    PRODUCT_AND_PRODUCT_GROUP_LINK ppgl
    --ON
    --    ppgl.PRODUCT_CENTER = pr.CENTER
    --    AND ppgl.PRODUCT_ID = pr.ID
    --AND ppgl.PRODUCT_GROUP_ID = 80
JOIN
    INVOICES inv
ON
    inv.CENTER = il.CENTER
    AND inv.id = il.ID
JOIN
    CASHREGISTERTRANSACTIONS crt
ON
    inv.PAYSESSIONID = crt.PAYSESSIONID
JOIN
    INSTALLMENT_PLANS ip
ON
    ip.ID = crt.INSTALLMENT_PLAN_ID
JOIN
    INSTALLMENT_PLAN_CONFIGS ipc
ON
    ipc.ID = ip.IP_CONFIG_ID
LEFT JOIN
    CLIPCARDS cc
ON
    cc.INVOICELINE_CENTER = il.CENTER
    AND cc.INVOICELINE_ID = il.ID
    AND cc.INVOICELINE_SUBID = il.SUBID
JOIN
    CENTERS c
ON
    c.id = il.CENTER
WHERE
    inv.CENTER IN ($$scope$$)
    AND inv.TRANS_TIME BETWEEN $$from_date$$ AND ($$to_date$$ + 24*60*60*1000)
