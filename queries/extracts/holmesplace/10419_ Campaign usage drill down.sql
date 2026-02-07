/*
select distinct cc.CAMPAIGN_TYPE from HP.CAMPAIGN_CODES cc
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
    prod.NAME product_name,
    pg.NAME prod_group_name,
    CASE WHEN inv.PAYER_CENTER IS NOT NULL THEN
        inv.PAYER_CENTER || 'p' || inv.PAYER_ID
    ELSE
        null
    END AS PID
FROM
     HP.PRIVILEGE_USAGES pu
JOIN HP.CAMPAIGN_CODES cc
ON
    pu.CAMPAIGN_CODE_ID = cc.ID
    AND pu.TARGET_SERVICE in ('InvoiceLine','SubscriptionPrice')
    AND pu.PRIVILEGE_TYPE = 'PRODUCT'
LEFT JOIN HP.INVOICELINES invl
ON
    invl.CENTER = pu.TARGET_CENTER
    AND invl.ID = pu.TARGET_ID
    AND invl.SUBID = pu.TARGET_SUBID
LEFT JOIN HP.INVOICES inv
ON
    inv.CENTER = invl.CENTER
    AND inv.ID = invl.ID
LEFT JOIN HP.CREDIT_NOTE_LINES cnl
ON
    cnl.INVOICELINE_CENTER = invl.CENTER
    AND cnl.INVOICELINE_ID = invl.ID
    AND cnl.INVOICELINE_SUBID = invl.SUBID
LEFT JOIN HP.PRODUCTS prod
ON
    prod.CENTER = invl.PRODUCTCENTER
    AND prod.ID = invl.PRODUCTID
LEFT JOIN HP.PRODUCT_GROUP pg
ON
    pg.ID = prod.PRIMARY_PRODUCT_GROUP_ID
LEFT JOIN HP.PRIVILEGE_RECEIVER_GROUPS prg
ON
    cc.CAMPAIGN_TYPE = 'RECEIVER_GROUP'
    AND prg.ID = cc.CAMPAIGN_ID
LEFT JOIN HP.STARTUP_CAMPAIGN sc
ON
    cc.CAMPAIGN_TYPE = 'STARTUP'
    AND sc.ID = cc.CAMPAIGN_ID
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