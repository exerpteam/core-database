-- The extract is extracted from Exerp on 2026-02-08
--  
SELECT
	DISTINCT s.center ||'p'|| s.ID MEMBERID,
    s.CENTER,
	s.id,
    pr.PRICE AS Default_Price,
    sp.price AS Reduced_Price,
    pr.name as PRODUCT, 
    ps.name AS Campaign_Name,
    sp.type
FROM
    subscription_price sp
JOIN
    SUBSCRIPTIONS s
ON
   sp.SUBSCRIPTION_CENTER = s.center
   AND sp.SUBSCRIPTION_ID = s.ID
JOIN
    PERSONS p
ON
   s.CENTER = p.center
   AND s.ID = p.ID        
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
     AND sp.price =0
