

SELECT
    c.NAME                          AS center,
    s.OWNER_CENTER||'p'||s.OWNER_ID AS memberid,
    s.SUBSCRIPTION_PRICE,
    COALESCE(TO_CHAR(srp.START_DATE,'dd.MM.YYYY'),TO_CHAR(sp.FROM_DATE,'dd.MM.YYYY')) AS Start_date,
    COALESCE(TO_CHAR(srp.END_DATE,'dd.MM.YYYY'),TO_CHAR(sp.TO_DATE,'dd.MM.YYYY'))     AS END_DATE,
    pr.NAME                                                                      AS "Subscription",
	srp.TYPE AS "Type",
    srp.TEXT AS "Comments"
FROM
    HP.SUBSCRIPTIONS s
LEFT JOIN
    HP.SUBSCRIPTION_REDUCED_PERIOD srp
ON
    s.center = srp.SUBSCRIPTION_CENTER
    AND s.id = srp.SUBSCRIPTION_ID
JOIN
    HP.PERSONS p
ON
    p.center = s.OWNER_CENTER
    AND p.id = s.OWNER_ID
JOIN
    HP.CENTERS c
ON
    c.id = p.CENTER
JOIN
    HP.PRODUCTS pr
ON
    pr.CENTER = s.SUBSCRIPTIONTYPE_CENTER
    AND pr.id = s.SUBSCRIPTIONTYPE_ID
LEFT JOIN
    HP.SUBSCRIPTION_PRICE sp
ON
    sp.SUBSCRIPTION_CENTER = s.CENTER
    AND sp.SUBSCRIPTION_ID = s.id
    -- AND sp.FROM_DATE <= CURRENT_DATE
    AND (
        sp.TO_DATE > CURRENT_DATE
        OR sp.TO_DATE IS NULL)
    AND sp.PRICE = 0
    AND sp.CANCELLED = 0
WHERE
    (((
                srp.END_DATE > CURRENT_DATE
                OR srp.END_DATE IS NULL)
            AND srp.TYPE IN ('SAVED_FREE_DAYS_USE',
                             'FREE_ASSIGNMENT') AND srp.state NOT IN ('CANCELLED'))
        OR s.SUBSCRIPTION_PRICE = 0
        OR sp.ID IS NOT NULL )
    AND s.CENTER IN ($$scope$$)
    AND s.STATE IN (2,4)
    AND p.PERSONTYPE !=2
    AND srp.START_DATE >= CURRENT_DATE
    AND NOT EXISTS
    (
        SELECT
            1
        FROM
            PRODUCT_AND_PRODUCT_GROUP_LINK ppg
        WHERE
            ppg.product_center = s.SUBSCRIPTIONTYPE_CENTER
            AND ppg.product_id = s.SUBSCRIPTIONTYPE_ID
            AND ppg.PRODUCT_GROUP_ID = 1201 )

