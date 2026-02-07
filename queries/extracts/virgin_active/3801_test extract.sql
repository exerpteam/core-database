SELECT
    cn.PAYER_CENTER || 'p' || cn.PAYER_ID payer_id,
    pp.FULLNAME,
    cnl.PERSON_CENTER || 'p' || cnl.PERSON_ID for_member,
    pu.FULLNAME,
    longToDate(cn.TRANS_TIME) transaction_time,
    'CREDIT_NOTE'                     TYPE,
    c.NAME                            center_name,
    prod.NAME,
    pg.NAME                                                                                                                                                                                                        product_group_name,
    DECODE(prod.PTYPE, 1, 'Retail', 2, 'Service', 4, 'Clipcard', 5, 'Subscription creation', 6, 'Transfer', 7, 'Freeze period', 8, 'Gift card', 9, 'Free gift card', 10, 'Subscription', 12, 'Subscription', 13, 'Subscription add-on') PT_TYPE,
    TO_CHAR( SUM(-1 * cnl.TOTAL_AMOUNT ), 'FM999999999999,9990.09' )                                                                                                                                                                    date_Revenue,
    TO_CHAR( SUM(-1 * cnl.TOTAL_AMOUNT / (1 + NVL(cnl.ORIG_RATE,0))), 'FM999999999999,9990.09' )                                                                                                                                        revenue_excl_vat,
    SUM(-1 * cnl.QUANTITY)                                                                                                                                                                                                        "count"
FROM
    CREDIT_NOTE_LINES cnl
JOIN
    PRODUCTS prod
ON
    prod.CENTER = cnl.PRODUCTCENTER
    AND prod.ID = cnl.PRODUCTID
JOIN
    PRODUCT_GROUP pg
ON
    pg.ID = prod.PRIMARY_PRODUCT_GROUP_ID
    AND (
        pg.id = 271
        OR pg.PARENT_PRODUCT_GROUP_ID = 271)
JOIN
    CREDIT_NOTES cn
ON
    cn.CENTER = cnl.CENTER
    AND cn.ID = cnl.ID
JOIN
    CENTERS c
ON
    c.ID = cn.CENTER
LEFT JOIN
    PERSONS pp
ON
    pp.CENTER = cn.PAYER_CENTER
    AND pp.id = cn.PAYER_ID
LEFT JOIN
    PERSONS pu
ON
    pu.CENTER = cnl.PERSON_CENTER
    AND pu.id = cnl.PERSON_ID
LEFT JOIN
    INVOICELINES invl
ON
    invl.CENTER = cnl.INVOICELINE_CENTER
    AND invl.ID = cnl.INVOICELINE_ID
    AND invl.SUBID = cnl.INVOICELINE_SUBID
LEFT JOIN
    SPP_INVOICELINES_LINK sppl
ON
    sppl.INVOICELINE_CENTER = invl.CENTER
    AND sppl.INVOICELINE_ID = invl.id
    AND sppl.INVOICELINE_SUBID = invl.SUBID
LEFT JOIN
    SUBSCRIPTIONPERIODPARTS spp
ON
    spp.CENTER = sppl.PERIOD_CENTER
    AND spp.id = sppl.PERIOD_ID
    AND spp.SUBID = sppl.PERIOD_SUBID
LEFT JOIN
    SUBSCRIPTION_ADDON sa
ON
    sa.SUBSCRIPTION_CENTER = sppl.PERIOD_CENTER
    AND sa.SUBSCRIPTION_ID = sppl.PERIOD_ID
    AND sa.START_DATE <= spp.FROM_DATE
    AND (
        sa.END_DATE >= SPP.TO_DATE
        OR sa.END_DATE IS NULL
        OR SA.CANCELLED = 1)
LEFT JOIN
    MASTERPRODUCTREGISTER mpr
ON
    mpr.ID = sa.ADDON_PRODUCT_ID
    AND mpr.GLOBALID = prod.GLOBALID
WHERE
    prod.PTYPE IN (4,10,12,13)
    AND (
        prod.PTYPE !=13
        OR mpr.id IS NOT NULL)
    /* Who to include */
    AND cn.TRANS_TIME BETWEEN $$fromDate$$ AND (
        $$toDate$$ + (1000 * 60 * 60 * 24)-1)
    AND ((
            prod.PTYPE !=13
            AND cn.CENTER IN ($$scope$$))
        OR (
            prod.PTYPE = 13
            AND sa.CENTER_ID IN ($$scope$$)))
            
GROUP BY
    cn.PAYER_CENTER || 'p' || cn.PAYER_ID ,
    cnl.PERSON_CENTER || 'p' || cnl.PERSON_ID ,
    pp.FULLNAME,
    pu.FULLNAME,
    longToDate(cn.TRANS_TIME) ,
    c.NAME ,
    prod.NAME ,
    pg.NAME ,
    DECODE(prod.PTYPE, 1, 'Retail', 2, 'Service', 4, 'Clipcard', 5, 'Subscription creation', 6, 'Transfer', 7, 'Freeze period', 8, 'Gift card', 9, 'Free gift card', 10, 'Subscription', 12, 'Subscription', 13, 'Subscription add-on')