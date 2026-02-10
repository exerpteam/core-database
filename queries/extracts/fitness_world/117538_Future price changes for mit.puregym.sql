-- The extract is extracted from Exerp on 2026-02-08
--  
WITH active_subscriptions AS (
    SELECT
        s.CENTER,
        s.ID AS SUBSCRIPTION_ID,
        s.OWNER_CENTER,
        s.OWNER_ID
    FROM SUBSCRIPTIONS s
    WHERE s.STATE IN (2,4)
      AND s.OWNER_CENTER || 'p' || s.OWNER_ID IN (:member_id)
),

dedup_prices AS (
    SELECT
        a.OWNER_CENTER,
        a.OWNER_ID,
        a.SUBSCRIPTION_ID,
        sp.FROM_DATE,
        MAX(sp.TO_DATE) AS TO_DATE,
        MAX(sp.PRICE)   AS PRICE
    FROM active_subscriptions a
    JOIN SUBSCRIPTION_PRICE sp
      ON sp.SUBSCRIPTION_CENTER = a.CENTER
     AND sp.SUBSCRIPTION_ID = a.SUBSCRIPTION_ID
    GROUP BY
        a.OWNER_CENTER,
        a.OWNER_ID,
        a.SUBSCRIPTION_ID,
        sp.FROM_DATE
),

current_price AS (
    SELECT *
    FROM dedup_prices
    ORDER BY FROM_DATE
    LIMIT 1
),

future_price AS (
    SELECT *
    FROM dedup_prices
    WHERE FROM_DATE > (SELECT TO_DATE FROM current_price)
    ORDER BY FROM_DATE
    LIMIT 1
)

SELECT
    OWNER_CENTER || 'p' || OWNER_ID AS PERSON_ID,
    FROM_DATE,
    TO_DATE,
    PRICE
FROM current_price

UNION ALL

SELECT
    OWNER_CENTER || 'p' || OWNER_ID AS PERSON_ID,
    FROM_DATE,
    TO_DATE,
    PRICE
FROM future_price

ORDER BY FROM_DATE;
