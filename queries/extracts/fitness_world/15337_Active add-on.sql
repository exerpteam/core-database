-- This is the version from 2026-02-05
--  
SELECT
    ss.owner_center||'p'||ss.owner_id AS customer,
    prod.globalid                     AS addon_product,
    sa.end_date                       AS end_date,
    sp.NAME                           AS subscription_name
FROM
    FW.SUBSCRIPTION_ADDON sa
JOIN
    FW.SUBSCRIPTIONS s
ON
    s.CENTER = sa.SUBSCRIPTION_CENTER
    AND s.ID = sa.SUBSCRIPTION_ID
JOIN
    FW.PRODUCTS sp
ON
    sp.CENTER = s.SUBSCRIPTIONTYPE_CENTER
    AND sp.ID = s.SUBSCRIPTIONTYPE_ID
JOIN
    FW.masterproductregister m
ON
    sa.addon_product_id = m.id
JOIN
    FW.subscription_sales ss
ON
    sa.subscription_center = ss.subscription_center
    AND sa.subscription_id= ss.subscription_id
JOIN
    FW.products prod
ON
    m.globalid = prod.globalid
JOIN
    FW.invoicelines invl
ON
    prod.ID = invl.PRODUCTID
    AND prod.CENTER = invl.PRODUCTCENTER
WHERE
    ss.owner_center IN (:scope)
    AND prod.globalid like 'ALL_IN%'
    AND NOT EXISTS
    (
        SELECT
            *
        FROM
            FW.CREDIT_NOTE_LINES cnl
        WHERE
            cnl.INVOICELINE_CENTER = invl.CENTER
            AND cnl.INVOICELINE_ID = invl.id
            AND cnl.INVOICELINE_SUBID = invl.SUBID )
    AND sa.start_date < to_date(TO_CHAR(exerpsysdate(),'yyyy-mm-dd'),'yyyy-mm-dd')
    AND (
        sa.end_date IS NULL
        OR sa.end_date > to_date(TO_CHAR(exerpsysdate(),'yyyy-mm-dd'),'yyyy-mm-dd') )
    AND sa.CANCELLED = 0
GROUP BY
    ss.owner_center,
    ss.owner_id,
    prod.globalid,
    sa.end_date,
    sp.NAME