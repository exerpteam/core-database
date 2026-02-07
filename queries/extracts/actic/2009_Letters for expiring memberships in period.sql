SELECT
    per.center || 'p' || per.id personid,
    per.ssn,
    per.FIRSTNAME,
    per.LASTNAME,
    per.ADDRESS1,
    per.ADDRESS2,
    per.ZIPCODE,
    per.CITY,
    TO_CHAR(sub.END_DATE, 'YYYY-MM-DD') end_DATE,
    CASE
        WHEN subType.ST_TYPE = 1
        THEN sub.SUBSCRIPTION_PRICE * 12 
        ELSE sub.SUBSCRIPTION_PRICE 
    END CASH_PRICE,
    CASE
        WHEN subType.ST_TYPE = 0
        THEN sub.SUBSCRIPTION_PRICE / subType.PERIODCOUNT 
        ELSE sub.SUBSCRIPTION_PRICE 
    END AG_PRICE,
    DECODE(subType.ST_TYPE, 0, 'KONTANT', 1, 'AUTOGIRO') type
FROM
    SUBSCRIPTIONS sub
LEFT JOIN SUBSCRIPTIONTYPES subType
ON
    subType.CENTER = sub.SUBSCRIPTIONTYPE_CENTER
    AND subType.ID = sub.SUBSCRIPTIONTYPE_ID
LEFT JOIN PRODUCTS prod
ON
    subType.CENTER = prod.CENTER
    AND subType.ID = prod.ID
JOIN persons per
ON
    sub.OWNER_CENTER = per.CENTER
    AND sub.OWNER_ID = per.ID
WHERE
    sub.center in (:ChosenScope)
    AND sub.END_DATE IS NOT NULL
    AND sub.END_DATE >= :FromDate
    AND sub.END_DATE < :ToDate + 1
ORDER BY per.center, per.id