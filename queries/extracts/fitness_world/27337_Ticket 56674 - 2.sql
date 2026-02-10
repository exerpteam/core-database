-- The extract is extracted from Exerp on 2026-02-08
--  
SELECT DISTINCT
    s.owner_center || 'p' || s.owner_id,
    sa.id,
    s.START_DATE,
    s.BILLED_UNTIL_DATE ,
    sa.END_DATE,
    prod.GLOBALID,
    invl.TOTAL_AMOUNT invoiced_last,
    prod.NAME product,
    months_between(spp.TO_DATE+1,spp.FROM_DATE) months_invoiced
FROM
    SUBSCRIPTIONS s
JOIN
    SUBSCRIPTIONPERIODPARTS spp
ON
    spp.CENTER = s.CENTER
    AND spp.ID = s.ID
    AND spp.SPP_STATE = 1
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
    AND invl.SUBID= link.INVOICELINE_SUBID
JOIN
    PRODUCTS prod
ON
    prod.CENTER = invl.PRODUCTCENTER
    AND prod.ID = invl.PRODUCTID
    AND prod.PTYPE = 13
JOIN
    SUBSCRIPTION_ADDON sa
ON
    sa.SUBSCRIPTION_CENTER = s.CENTER
    AND sa.SUBSCRIPTION_ID = s.ID
JOIN
    MASTERPRODUCTREGISTER mpr
ON
    mpr.ID = sa.ADDON_PRODUCT_ID
WHERE
    prod.GLOBALID IN ('ALL_IN',
                      'ALL_IN__FØDSELSDAG_','ALL_IN__PERSONALE_')
    AND sa.END_DATE = to_date('2015-03-31','YYYY-MM-DD')
    AND s.BILLED_UNTIL_DATE = to_date('2015-02-28','YYYY-MM-DD')
    AND spp.TO_DATE = to_date('2015-02-28','YYYY-MM-DD')
    AND invl.TOTAL_AMOUNT = 0