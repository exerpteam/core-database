-- The extract is extracted from Exerp on 2026-02-08
--  
SELECT
    p.CENTER||'p'||p.ID                                                                    AS "Member ID",
    p.FULLNAME                                                                             AS "Member Name",
    s.CENTER||'ss'||s.ID                                                                   AS "Subscription ID",
    products.name                                                                          AS "Subscription name",
    DECODE (s.STATE, 2,'ACTIVE', 3,'ENDED', 4,'FROZEN', 7,'WINDOW', 8,'CREATED','UNKNOWN') AS "Subscription State",
    s.SUBSCRIPTION_PRICE                                                                   AS "Current price"
FROM
    SUBSCRIPTIONS s  
JOIN
    persons p
ON
    s.OWNER_CENTER = p.CENTER
    AND p.ID = s.OWNER_ID
LEFT JOIN 
    SubscriptionTypes 
    ON 
    s.SubscriptionType_Center = SubscriptionTypes.Center 
    AND s.SubscriptionType_ID = SubscriptionTypes.ID 
LEFT JOIN 
    Products 
    ON 
    SubscriptionTypes.Center = Products.Center 
    AND SubscriptionTypes.Id = Products.Id 
WHERE
products.name = 'Fitness og Hold (gl)'
and s.STATE in (2,4,7,8)