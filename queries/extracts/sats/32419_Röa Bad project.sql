SELECT
    p.center||'p'||p.id AS "Customer number",
    e.IDENTITY          AS membercard,
    p.FIRSTNAME,
    p.LASTNAME,
    s.END_DATE,
    CASE
        WHEN pr.GLOBALID IN ('PRIORITY2_EFT_12_MONTHS',
                             'PRIORITY2_EFT_24_MONTHS',
                             'PRIORITY_EFT_NO_BINDING',
                             'PRIORITY_CASH_12_MONTHS',
                             'PRIORITY_CASH_24_MONTHS',
                             'CORPORATE_6_MONTHS_FREE',
                             'CORPORATE_PRIORITY_EFT_12',
                             'CORPORATE_PRIORITY_CASH_12',
                             'Free')
        THEN 'access1'
        WHEN p.PERSONTYPE = 2
        THEN 'access1'
        WHEN s.CENTER = 251
        THEN 'access1'
    END AS "Access1",
    CASE
        WHEN pr.GLOBALID IN ('WATER_PARK_MEMBERSHIP',
                             'WATER_PARK_COMBO_MEMBERSHIP')
            OR sa.SUBSCRIPTION_CENTER IS NOT NULL
        THEN 'access2'
    END AS "Access2"
FROM
    SATS.PERSONS p
LEFT JOIN
    SATS.ENTITYIDENTIFIERS e
ON
    e.REF_CENTER = p.CENTER
    AND e.REF_ID = p.ID
    AND e.IDMETHOD = 4
    AND e.ENTITYSTATUS = 1
JOIN
    SATS.SUBSCRIPTIONS s
ON
    s.OWNER_CENTER = p.CENTER
    AND s.OWNER_ID = p.ID
    AND s.STATE IN (2,4)
JOIN
    SATS.PRODUCTS pr
ON
    pr.CENTER = s.SUBSCRIPTIONTYPE_CENTER
    AND pr.id = s.SUBSCRIPTIONTYPE_ID
LEFT JOIN
    (
        SELECT
            sa.SUBSCRIPTION_CENTER ,
            sa.SUBSCRIPTION_ID,
            mpr.GLOBALID
        FROM
            SATS.SUBSCRIPTION_ADDON sa
        JOIN
            SATS.MASTERPRODUCTREGISTER mpr
        ON
            mpr.ID = sa.ADDON_PRODUCT_ID
            AND mpr.GLOBALID IN ('BADELAND_ADD_ON',
                                 'BADELAND_CASH_ADD_ON',
                                 'BADELAND_NO_BINDING_ADD_O')
        WHERE
            sa.CANCELLED = 0
            AND sa.START_DATE <=exerpsysdate()
            AND (
                sa.END_DATE > exerpsysdate()
                OR sa.END_DATE IS NULL)) sa
ON
    sa.SUBSCRIPTION_CENTER = s.CENTER
    AND sa.SUBSCRIPTION_ID = s.ID
WHERE
    (
        pr.GLOBALID IN ('PRIORITY2_EFT_24_MONTHS',
                        'PRIORITY_EFT_NO_BINDING',
                        'PRIORITY_CASH_12_MONTHS',
                        'PRIORITY_CASH_24_MONTHS',
                        'CORPORATE_6_MONTHS_FREE',
                        'CORPORATE_PRIORITY_EFT_12',
                        'CORPORATE_PRIORITY_CASH_12',
                        'WATER_PARK_MEMBERSHIP',
                        'WATER_PARK_COMBO_MEMBERSHIP',
                        'Free')
        OR sa.SUBSCRIPTION_CENTER IS NOT NULL
        OR p.PERSONTYPE = 2
        OR s.center = 251)
    --and p.id = 4344