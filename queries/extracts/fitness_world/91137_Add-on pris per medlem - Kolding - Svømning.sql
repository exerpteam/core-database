-- The extract is extracted from Exerp on 2026-02-08
--  
SELECT
    p.center ||'p'|| p.id AS MemberID,
    p.fullname AS Membername,
    mpr.CACHED_PRODUCTNAME AS Productname,
    CASE
        WHEN sa.USE_INDIVIDUAL_PRICE = 1
        THEN sa.INDIVIDUAL_PRICE_PER_UNIT
        ELSE mpr.CACHED_PRODUCTPRICE
    END AS Price,
    TO_CHAR(sa.START_DATE, 'dd-MM-YYYY') AS Start_date,
    TO_CHAR(sa.END_DATE, 'dd-MM-YYYY') AS End_date
FROM
    persons p
JOIN
    subscriptions s
ON
    s.OWNER_CENTER = p.center
AND s.owner_id = p.id
JOIN
    SUBSCRIPTION_ADDON sa
ON
    sa.SUBSCRIPTION_CENTER = s.center
AND sa.SUBSCRIPTION_ID = s.id
JOIN
    FW.MASTERPRODUCTREGISTER mpr
ON
    mpr.id = sa.ADDON_PRODUCT_ID
AND sa.ADDON_PRODUCT_ID = 70418
WHERE
    sa.CANCELLED = 0
AND (
        sa.END_DATE > CURRENT_DATE
    OR  sa.END_DATE IS NULL)
ORDER BY
Price