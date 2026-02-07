-- This is the version from 2026-02-05
--  
SELECT
    TO_CHAR(exerpro.LongToDate(inv.TRANS_TIME),'YYYY-MM-DD') invoiced,
    prod.NAME                                                addon_name,
    prod.PRICE                                               current_price,
    invl.PRODUCT_NORMAL_PRICE                                price_without_discount,
    invl.TOTAL_AMOUNT                                        invoiced_amount,
    prg.NAME                                                 recever_group,
    pg.GRANTER_SERVICE,
    COUNT(invl.CENTER) invoice_lines
FROM
    SUBSCRIPTION_ADDON sa
JOIN
    SUBSCRIPTIONS s
ON
    s.CENTER = sa.SUBSCRIPTION_CENTER
    AND s.ID = sa.SUBSCRIPTION_ID
JOIN
    SUBSCRIPTIONPERIODPARTS spp
ON
    spp.CENTER = s.CENTER
    AND spp.ID = s.ID
JOIN
    SPP_INVOICELINES_LINK link
ON
    link.PERIOD_CENTER = spp.CENTER
    AND link.PERIOD_ID = spp.ID
    AND link.PERIOD_SUBID = spp.SUBID
JOIN
    INVOICELINES invl
ON
    invl.CENTER = link.INVOICELINE_CENTER
    AND invl.ID = link.INVOICELINE_ID
    AND invl.SUBID = link.INVOICELINE_SUBID
JOIN
    INVOICES inv
ON
    inv.CENTER = invl.CENTER
    AND inv.ID = invl.ID
JOIN
    PRODUCTS prod
ON
    prod.CENTER = invl.PRODUCTCENTER
    AND prod.ID = invl.PRODUCTID
    AND prod.PTYPE = 13
LEFT JOIN
    PRIVILEGE_USAGES pu
ON
    pu.TARGET_SERVICE = 'InvoiceLine'
    AND pu.TARGET_CENTER = invl.CENTER
    AND pu.TARGET_ID = invl.ID
    AND pu.TARGET_SUBID = invl.SUBID
LEFT JOIN
    PRIVILEGE_GRANTS pg
ON
    pg.ID = pu.GRANT_ID
LEFT JOIN
    PRIVILEGE_RECEIVER_GROUPS prg
ON
    prg.ID = pg.GRANTER_ID
    AND pg.GRANTER_SERVICE = 'ReceiverGroup'
WHERE
    inv.TRANS_TIME BETWEEN $$fromDate$$ AND (
        $$toDate$$ + 1000*60*60*24)
GROUP BY
    TO_CHAR(exerpro.LongToDate(inv.TRANS_TIME),'YYYY-MM-DD'),
    prod.NAME ,
    prod.PRICE ,
    invl.PRODUCT_NORMAL_PRICE ,
    invl.TOTAL_AMOUNT ,
    prg.NAME ,
    pg.GRANTER_SERVICE