SELECT DISTINCT
	 s.OWNER_CENTER AS CLUB,
     s.OWNER_CENTER||'p'|| s.OWNER_ID	AS MEMBER_ID,                                                                                                                                                   
     sa.id AS Subscription_Addon_key,
     sa.SUBSCRIPTION_CENTER ||'ss'|| sa.SUBSCRIPTION_id AS main_subscription_key,
     p.NAME AS SUBSCRIPTION_NAME,                                                                                                                                                                                
     CASE  s.state  WHEN 2 THEN 'Active'  WHEN 3 THEN 'Ended'  WHEN 4 THEN 'Frozen'  WHEN 7 THEN 'Window'  WHEN 8 THEN 	'Created' ELSE 'Unknown' END AS SUBSCRIPTION_STATE,                                                                                                    
     s.START_DATE AS SUBSCRIPTION_START_DATE,                                                                                                                                                                                
     mpr.CACHED_PRODUCTNAME AS ADD_ON_NAME,                                                                                                                                                                                                                                                                                                                                                       
     a.name as Level_Of_Service

 FROM SUBSCRIPTIONS s

JOIN CENTERS c ON c.ID = s.OWNER_CENTER AND c.COUNTRY = 'IT'
JOIN SUBSCRIPTIONTYPES st ON st.center = s.SUBSCRIPTIONTYPE_CENTER AND st.id = s.SUBSCRIPTIONTYPE_ID
JOIN PRODUCTS p ON p.center = st.center AND p.id = st.id
LEFT JOIN SUBSCRIPTION_ADDON sa ON sa.SUBSCRIPTION_CENTER = s.center AND sa.SUBSCRIPTION_ID = s.id
LEFT JOIN MASTERPRODUCTREGISTER mpr ON mpr.id= sa.ADDON_PRODUCT_ID
JOIN PERSONS per ON per.center = s.OWNER_CENTER AND per.id = s.OWNER_ID
JOIN AREA_CENTERS ac ON ac.center = per.center
JOIN areas a ON a.id = ac.area AND a.ROOT_AREA = 1

 WHERE
s.state IN (2, 4, 8) -- ACTIVE, FROZEN, CREATED   
AND s.center IN ($$scope$$)
