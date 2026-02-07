SELECT DISTINCT
    s.OWNER_CENTER||'p'|| s.OWNER_ID AS MEMBER_ID,                                                                                                                                                      
	sa.id AS "Subscription add-on key",
    sa.SUBSCRIPTION_CENTER ||'ss'|| sa.SUBSCRIPTION_id AS 		"Main_subscription_key",                                                                                                
    s.START_DATE AS SUBSCRIPTION_START_DATE,                                                                                                                                                                                                                                                                                                                                                    
    sa.START_DATE AS ADD_ON_START_DATE,                                                                                                                                                                                
    sa.END_DATE AS ADD_ON_END_DATE                                                                                                                                                                               
FROM
    SUBSCRIPTIONS s
JOIN
    SUBSCRIPTION_ADDON sa
 	ON sa.SUBSCRIPTION_CENTER = s.center
    AND sa.SUBSCRIPTION_ID = s.id
WHERE
	s.state IN (2, 4, 8) -- ACTIVE, FROZEN, CREATED
	AND (sa.CANCELLED = 'false' OR sa.CANCELLED IS NULL)
	AND s.center IN ($$scope$$)