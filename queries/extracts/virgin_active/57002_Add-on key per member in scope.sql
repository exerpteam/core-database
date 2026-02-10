-- The extract is extracted from Exerp on 2026-02-08
--  
SELECT distinct
    p.center ||'p'|| p.id as memberid, 
    p.center as owner_center,
	sa.center_id 								  as add_on_scope,
    prod.name                                    AS add_on_name,
   	sa.id as "Subscription add-on key",
    sa.SUBSCRIPTION_CENTER ||'ss'|| sa.SUBSCRIPTION_id as 	main_subscription_key,
	s.end_date as sub_end_date,
	prod2.name as main_subscription_name,
    sa.ADDON_PRODUCT_ID,
    sa.START_DATE as addon_start_date,
    sa.END_DATE as addon_end_date,
    sa.INDIVIDUAL_PRICE_PER_UNIT,
    p.firstname,
    p.lastname,
    p.Address1|| ' ' ||p.Address2 AS address,
    p.zipcode,
    p.city 
		FROM
            SUBSCRIPTION_ADDON sa
		
        left join centers sa_c on sa_c.id = sa.CENTER_ID
        JOIN
            SUBSCRIPTIONS s
        ON
            s.CENTER = sa.SUBSCRIPTION_CENTER
            AND s.ID = sa.SUBSCRIPTION_ID
        JOIN
            PERSONS p
        ON
            p.CENTER = s.OWNER_CENTER
            AND p.ID = s.OWNER_ID
left JOIN masterproductregister m
ON
    sa.addon_product_id = m.id
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
where 
 p.center  in (:scope)
and sa.cancelled = 0
and (sa.END_DATE > current_date or sa.end_date is null)