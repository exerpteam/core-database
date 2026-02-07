SELECT
    s.OWNER_CENTER||'p'||s.OWNER_ID      AS MEMBERID,
    c.id                                 AS Center_ID,
    c.NAME                               AS Center_Name,
    DECODE(s.STATE,2,'Active','Unknown') AS Subscription_State,
    CASE
        WHEN mpr.id IS NOT NULL
        THEN mpr.CACHED_PRODUCTNAME
        ELSE pr.NAME
    END AS subscription_name,
    CASE
        WHEN mpr.id IS NOT NULL
        THEN mpr.GLOBALID
        ELSE pr.GLOBALID
    END                              AS subscription_Global_ID,
    DECODE(r.CENTER,NULL,'No','Yes') AS Other_Payer,
    CASE
        WHEN r.center IS NOT NULL
        THEN r.CENTER||'p'|| r.id
    END AS Payer_ID,
    CASE
        WHEN mpr.id IS NOT NULL
        THEN nvl(sa.INDIVIDUAL_PRICE_PER_UNIT,pr2.PRICE)
        ELSE s.SUBSCRIPTION_PRICE
    END AS subscription_price
FROM
    SUBSCRIPTIONS s
JOIN
    PRODUCTS pr
ON
    pr.CENTER = s.SUBSCRIPTIONTYPE_CENTER
    AND pr.id = s.SUBSCRIPTIONTYPE_ID
    AND s.STATE = 2
LEFT JOIN
    SUBSCRIPTION_ADDON sa
ON
    sa.SUBSCRIPTION_CENTER = s.CENTER
    AND sa.SUBSCRIPTION_ID = s.id
    AND sa.START_DATE <=exerpsysdate()
    AND (
        sa.END_DATE IS NULL
        OR sa.END_DATE > exerpsysdate())
LEFT JOIN
    MASTERPRODUCTREGISTER mpr
ON
    mpr.id = sa.ADDON_PRODUCT_ID
LEFT JOIN
    PRODUCTS pr2
ON
    pr2.GLOBALID = mpr.GLOBALID
    AND pr2.CENTER = s.CENTER
LEFT JOIN
    RELATIVES r
ON
    r.RELATIVECENTER = s.OWNER_CENTER
    AND r.RELATIVEID = s.OWNER_ID
    AND r.RTYPE = 12
    AND r.STATUS = 1
JOIN
    CENTERS c
ON
    c.id = s.center
WHERE
    (
        pr.GLOBALID IN ('ADD_ON_CLASSES_EFT',
                        'AVTALEGIRO_MEDLEMSKAP_INKL._GR',
                        'CASH_12_MONTHE_INCLUDING_GROUP',
                        'CASH_3_MONTH_INCL_GX',
                        'CASH_6_MONTH_INCL_GX')                                              
        OR mpr.GLOBALID IN ('CASH_GX_ADD_ON_1',
                            'EFT_GX_ADD_ON_1'))
    AND s.center IN (211,
                     216,
                     209,
                     222,
                     213,
                     215,
                     226,
                     207,
                     214,
                     224,
                     206,
                     201,
                     205,
                     227,
                     221,
                     225,
                     204,
                     223 )
ORDER BY
    2