-- This is the version from 2026-02-05
--  
SELECT
    s.owner_center ||'p'|| s.owner_id AS Member_ID,
	p.persontype AS Persontype, 
    pr.PRICE AS Default_Price,
    sp.price AS Reduced_Price,
    pr.name as PRODUCT, 
    ps.name AS Campaign_Name,
    sp.type,
	sp.FROM_DATE,
    sp.TO_DATE
FROM
    subscription_price sp
JOIN
    SUBSCRIPTIONS s
ON
   sp.SUBSCRIPTION_CENTER = s.center
   AND sp.SUBSCRIPTION_ID = s.ID
LEFT JOIN
    PERSONS p
ON
p.CENTER = s.OWNER_CENTER
AND p.ID = s.OWNER_ID
     
JOIN
   PRODUCTS pr
ON
   pr.CENTER = s.SUBSCRIPTIONTYPE_CENTER
   AND pr.ID = s.SUBSCRIPTIONTYPE_ID         
LEFT JOIN
   PRIVILEGE_USAGES pu
ON 
   pu.TARGET_SERVICE = 'SubscriptionPrice'
   AND sp.ID = pu.TARGET_ID
   AND pu.STATE = 'USED'
LEFT JOIN
   PRIVILEGE_GRANTS pg
ON
   pg.ID = pu.GRANT_ID
LEFT JOIN
   PRIVILEGE_SETS ps
ON 
   pg.PRIVILEGE_SET = ps.id      
WHERE
   sp.subscription_center in (:Scope)
   AND s.state in (2,4)
   AND sp.applied = 1 
   AND sp.cancelled = 0 
--   AND sp.from_date <= sysdate 
   AND (sp.to_date is null OR sp.to_date >= sysdate)
   AND pr.PRICE != sp.price

ORDER BY 1 DESC