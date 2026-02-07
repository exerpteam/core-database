/*
select distinct cc.CAMPAIGN_TYPE from CAMPAIGN_CODES cc
CAMPAIGN_TYPE
RECEIVER_GROUP
STARTUP
*/
SELECT
    NVL(prg.NAME,sc.NAME) campaign_name,
    cc.CAMPAIGN_TYPE,
    longToDate(inv.TRANS_TIME) used,
    cc.CODE,
    inv.CENTER purchase_center,
    CASE WHEN inv.CENTER IS NOT NULL THEN 
        inv.CENTER || 'inv' || inv.ID
    ELSE
        null
    END AS inv_id,
    invl.QUANTITY,
    invl.PRODUCT_NORMAL_PRICE,
    invl.TOTAL_AMOUNT invl_amount,
    cnl.TOTAL_AMOUNT cnl_amount,
    (CASE
        WHEN pu.TARGET_SERVICE = 'InvoiceLine' THEN  prod.NAME 
        ELSE mp.NAME
    END) AS product_name,
    (CASE
        WHEN pu.TARGET_SERVICE = 'InvoiceLine' THEN  pg.NAME 
        ELSE pg2.NAME
    END) AS prod_group_name,
    CASE WHEN inv.PAYER_CENTER IS NOT NULL THEN
        inv.PAYER_CENTER || 'p' || inv.PAYER_ID
    ELSE
        null
    END AS PID,
    pu.PERSON_CENTER || 'p' || pu.PERSON_ID AS UsedBy
FROM
    CAMPAIGN_CODES cc
JOIN PRIVILEGE_USAGES pu
ON
    pu.CAMPAIGN_CODE_ID = cc.ID
    AND pu.TARGET_SERVICE in ('InvoiceLine','SubscriptionPrice')
    AND pu.PRIVILEGE_TYPE = 'PRODUCT'
LEFT JOIN INVOICELINES invl
ON
    invl.CENTER = pu.TARGET_CENTER
    AND invl.ID = pu.TARGET_ID
    AND invl.SUBID = pu.TARGET_SUBID
LEFT JOIN INVOICES inv
ON
    inv.CENTER = invl.CENTER
    AND inv.ID = invl.ID
LEFT JOIN CREDIT_NOTE_LINES cnl
ON
    cnl.INVOICELINE_CENTER = invl.CENTER
    AND cnl.INVOICELINE_ID = invl.ID
    AND cnl.INVOICELINE_SUBID = invl.SUBID
LEFT JOIN PRODUCTS prod
ON
    prod.CENTER = invl.PRODUCTCENTER
    AND prod.ID = invl.PRODUCTID
LEFT JOIN PRODUCT_GROUP pg
ON
    pg.ID = prod.PRIMARY_PRODUCT_GROUP_ID
LEFT JOIN PRIVILEGE_RECEIVER_GROUPS prg
ON
    cc.CAMPAIGN_TYPE = 'RECEIVER_GROUP'
    AND prg.ID = cc.CAMPAIGN_ID
LEFT JOIN STARTUP_CAMPAIGN sc
ON
    cc.CAMPAIGN_TYPE = 'STARTUP'
    AND sc.ID = cc.CAMPAIGN_ID
LEFT JOIN SUBSCRIPTION_PRICE sp ON sp.ID = pu.TARGET_ID AND pu.TARGET_SERVICE IN ('SubscriptionPrice')
LEFT JOIN SUBSCRIPTIONS s ON s.CENTER = sp.SUBSCRIPTION_CENTER AND s.ID = sp.SUBSCRIPTION_ID
LEFT JOIN PRODUCTS mp ON s.SUBSCRIPTIONTYPE_CENTER = mp.CENTER AND s.SUBSCRIPTIONTYPE_ID = mp.ID
LEFT JOIN PRODUCT_GROUP pg2 ON pg2.ID = mp.PRIMARY_PRODUCT_GROUP_ID
WHERE
    (
        (:searchType = 'CODE'
        AND cc.CODE = :code)
        OR
        (
            :searchType = 'CAMPAIGN'
            AND
            (
                sc.NAME = :campaignName
                OR prg.NAME = :campaignName
            )
        )
    )