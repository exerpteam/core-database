SELECT
    s.OWNER_CENTER || 'p' || s.OWNER_ID pis,
    s.CENTER || 'ss' || s.ID            ssid,
    invl.TEXT,
    invl.PRODUCT_NORMAL_PRICE LIST_PRICE_AT_INVOICING,
    invl.TOTAL_AMOUNT PAID_PRICE_AFTER_DISCOUNT,
    prod.PRICE CURRENT_MONTHLY_PRICE,
    longToDate(sfp.ENTRY_TIME) FREEZE_ENTRY_TIME,
    sfp.START_DATE                     FREEZE_START,
    sfp.END_DATE                       FREEZE_END,
    spp.FROM_DATE                      PERIOD_FROM,
    spp.TO_DATE                        PERIOD_TO
FROM
    PRIVILEGE_USAGES pu
JOIN
    PRIVILEGE_GRANTS pg
ON
    pg.ID = pu.GRANT_ID
    AND pg.GRANTER_SERVICE = 'ReceiverGroup'
    AND pg.GRANTER_ID = 5602
JOIN
    INVOICELINES invl
ON
    invl.CENTER = pu.TARGET_CENTER
    AND invl.ID = pu.TARGET_ID
    AND invl.SUBID = pu.TARGET_SUBID
    AND pu.TARGET_SERVICE = 'InvoiceLine'
JOIN
    PRODUCTS prod
ON
    prod.CENTER = invl.PRODUCTCENTER
    AND prod.ID = invl.PRODUCTID
JOIN
    SPP_INVOICELINES_LINK link
ON
    link.INVOICELINE_CENTER = invl.CENTER
    AND link.INVOICELINE_ID = invl.ID
    AND link.INVOICELINE_SUBID = invl.SUBID
JOIN
    SUBSCRIPTIONPERIODPARTS spp
ON
    spp.CENTER = link.PERIOD_CENTER
    AND spp.ID = link.PERIOD_ID
    AND spp.SUBID = link.PERIOD_SUBID
JOIN
    SUBSCRIPTIONS s
ON
    s.CENTER = spp.CENTER
    AND s.id = spp.id
LEFT JOIN
    SUBSCRIPTION_FREEZE_PERIOD sfp
ON
    spp.FROM_DATE BETWEEN sfp.START_DATE AND sfp.END_DATE
    AND sfp.STATE = 'ACTIVE'
    and sfp.SUBSCRIPTION_CENTER = s.CENTER and sfp.SUBSCRIPTION_ID = s.id