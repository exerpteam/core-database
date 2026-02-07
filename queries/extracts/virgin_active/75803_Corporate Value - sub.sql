SELECT distinct
    p.center ||'p'|| p.id as memberid, 
    p.center as owner_center,
	prod2.name as main_subscription_name,
	pea.txtvalue AS corporate_value,
    p.firstname,
    p.lastname
FROM
	SUBSCRIPTIONS s
JOIN
	PERSONS p
ON
	p.CENTER = s.OWNER_CENTER
	AND p.ID = s.OWNER_ID
left JOIN masterproductregister m
ON
    s.id = m.id
LEFT JOIN products prod
ON
    m.globalid = prod.globalid
left JOIN 
    SubscriptionTypes st
    ON 
    s.SubscriptionType_Center = st.Center 
    AND S.SubscriptionType_ID = st.ID 
LEFT JOIN products prod2
ON
    St.Center = Prod2.Center 
    AND St.Id = Prod2.Id 
LEFT JOIN PERSON_EXT_ATTRS pea
ON pea.PERSONCENTER = p.CENTER AND pea.PERSONID = p.ID 
AND pea.NAME = 'Corporatevalue'
where 
 p.center  in (:scope)
and s.state in (:Subscription_state)
