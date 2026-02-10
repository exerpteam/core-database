-- The extract is extracted from Exerp on 2026-02-08
--  
WITH prices AS (
    SELECT 
        s.OWNER_CENTER,
        s.OWNER_ID,
        sp.FROM_DATE,
        sp.TO_DATE,
        cast(sp.PRICE as varchar) AS PRICE,
        ROW_NUMBER() OVER (
            PARTITION BY s.OWNER_CENTER, s.OWNER_ID, sp.SUBSCRIPTION_ID
            ORDER BY sp.FROM_DATE DESC
        ) AS rn
    FROM SUBSCRIPTIONS s
    LEFT JOIN SUBSCRIPTION_PRICE sp
        ON sp.SUBSCRIPTION_CENTER = s.CENTER
       AND sp.SUBSCRIPTION_ID = s.ID
    WHERE s.OWNER_CENTER || 'p' || s.OWNER_ID IN (:member_id)
      AND s.STATE IN (2,8)
)
SELECT 
    prices.OWNER_CENTER || 'p' || prices.OWNER_ID AS PERSON_ID,
    FROM_DATE,
    TO_DATE,
    PRICE
FROM prices
WHERE 
      (TO_DATE IS NOT NULL AND TO_DATE >= CURRENT_DATE)
   OR (TO_DATE IS NULL AND rn = 1)
ORDER BY PERSON_ID, FROM_DATE;
