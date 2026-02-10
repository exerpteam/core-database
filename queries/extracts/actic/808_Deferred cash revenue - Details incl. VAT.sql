-- The extract is extracted from Exerp on 2026-02-08
--  
SELECT
    sub.center,
    prod.NAME,
    sub.OWNER_CENTER || 'p' || sub.OWNER_ID personid,
    TO_CHAR(sub.START_DATE,'YYYY-MM-DD') startdate,
    TO_CHAR(sub.END_DATE,'YYYY-MM-DD') enddate,
    sub.END_DATE - sub.START_DATE + 1 totaldays,
    sub.SUBSCRIPTION_PRICE,
    ROUND(sub.SUBSCRIPTION_PRICE / (sub.END_DATE - sub.START_DATE + 1), 2) dailyprice,
    :ToDate - sub.START_DATE + 1 realized_days,
    sub.END_DATE - :ToDate deferred_days,
    ROUND((:ToDate - sub.START_DATE + 1) * (sub.SUBSCRIPTION_PRICE / (sub.END_DATE -
    sub.START_DATE + 1)), 2) realized_amount,
    ROUND((sub.END_DATE - :ToDate) * (sub.SUBSCRIPTION_PRICE / (sub.END_DATE -
    sub.START_DATE + 1)), 2) deferred_amount
FROM
    subscriptions sub
LEFT JOIN SUBSCRIPTIONTYPES subType
ON
    subType.CENTER = sub.SUBSCRIPTIONTYPE_CENTER
    AND subType.ID = sub.SUBSCRIPTIONTYPE_ID
LEFT JOIN PRODUCTS prod
ON
    subType.CENTER = prod.CENTER
    AND subType.ID = prod.ID
WHERE
    sub.center IN (:scope)
    --AND subType.ST_TYPE = 0
    AND sub.START_DATE <= :ToDate
    AND sub.END_DATE > :ToDate
    AND sub.STATE IN (2,4)
order by sub.START_DATE