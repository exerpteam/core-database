-- The extract is extracted from Exerp on 2026-02-08
-- Passed to "Storm" extract. You can overwrite this one
SELECT 
    p.CENTER ||'p'|| p.ID           AS "Member ID",
    p.FULLNAME                      AS "Fullname",
    sub.start_date                  AS "Subsciption Startdate"
FROM 
    PERSONS p 
LEFT JOIN 
    SUBSCRIPTIONS sub 
ON 
    p.CENTER = sub.OWNER_CENTER
    AND p.ID = sub.OWNER_ID
JOIN 
    SUBSCRIPTION_SALES ss 
ON  
    sub.CENTER = ss.SUBSCRIPTION_CENTER 
    AND sub.ID = ss.SUBSCRIPTION_ID 
JOIN 
    SUBSCRIPTIONTYPES stype  
ON 
    ss.SUBSCRIPTION_TYPE_CENTER = stype.CENTER
    AND ss.SUBSCRIPTION_TYPE_ID = stype.ID
JOIN
    PRODUCTS prod
ON
    stype.CENTER = prod.CENTER
    AND stype.ID = prod.ID
WHERE 
    sub.STATE = 2
    AND prod.name = 'Classic 12 Month VIP'
	AND p.CENTER IN ($$Scope$$)