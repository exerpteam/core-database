SELECT 
----------------------------------------------------------------
    cen.COUNTRY,
	cen.EXTERNAL_ID 								AS Cost,
	cen.ID 											AS CenterId,
	cen.name,
	sub.OWNER_CENTER || 'p' || sub.OWNER_ID 		AS PersonId,
		TO_CHAR(trunc(months_between(TRUNC(exerpsysdate()),scl_ptype.birthdate)/12)) AS Age,

    DECODE (scl_ptype.PERSONTYPE, 0,'PRIVATE', 1,'STUDENT', 2,'STAFF', 3,'FRIEND', 4,'CORPORATE', 5,'ONEMANCORPORATE', 6,'FAMILY', 7,'SENIOR', 8,'GUEST', 9,'CONTACT', 'UNKNOWN') AS PERSONTYPE,
	sub.CENTER || 'ss' || sub.ID					AS SubscriptionId,
    DECODE (sub.STATE, 2,'ACTIVE', 3,'ENDED', 4,'FROZEN', 7,'WINDOW', 8,'CREATED','UNKNOWN') AS subscription_STATE,
    DECODE (sub.SUB_STATE, 1,'NONE', 2,'AWAITING_ACTIVATION', 3,'UPGRADED', 4,'DOWNGRADED', 5,'EXTENDED', 6, 'TRANSFERRED',7,'REGRETTED',8,'CANCELLED',9,'BLOCKED','UNKNOWN')  AS SUBSCRIPTION_SUB_STATE,
    DECODE(st.ST_TYPE, 0, 'CASH', 1, 'EFT', 'UKNOWN') as PaymentType,
	TO_CHAR(longToDate(sub.CREATION_TIME), 'YYYY-MM-DD') AS Sales_Date,
	TO_CHAR(sub.START_DATE, 'YYYY-MM-DD') 			AS start_DATE,	
	TO_CHAR(sub.BINDING_END_DATE, 'YYYY-MM-DD') 	AS binding_END_DATE,
	TO_CHAR(sub.END_DATE, 'YYYY-MM-DD')				AS end_DATE,
	sub.BINDING_PRICE,
	sub.SUBSCRIPTION_PRICE,
sp.price,
sp.from_date,
Sp.to_date,
sp.cancelled,


	CASE
		WHEN ss.SUBSCRIPTION_TYPE_TYPE = 0 THEN ceil(( ss.PRICE_PERIOD /( ( ss.END_DATE - ss.START_DATE)-2) )*30) -- cash pr month
		WHEN ss.SUBSCRIPTION_TYPE_TYPE = 1 THEN sp.PRICE
	END   AS MonthlyPrice,
	Sub.BILLED_UNTIL_DATE,
	prod.price as List_price,
	prod.NAME AS Product_Name,
	prod.GLOBALID AS Global_Id
	-------------------------------------------------------------

FROM SUBSCRIPTIONS sub
INNER JOIN SUBSCRIPTIONTYPES st
ON
	sub.SUBSCRIPTIONTYPE_CENTER = st.CENTER
	AND sub.SUBSCRIPTIONTYPE_ID = st.ID
LEFT JOIN SUBSCRIPTIONTYPES st
ON
    st.CENTER = sub.SUBSCRIPTIONTYPE_CENTER
    AND st.ID = sub.SUBSCRIPTIONTYPE_ID
	
LEFT JOIN SUBSCRIPTION_SALES ss
ON
	sub.CENTER = ss.SUBSCRIPTION_CENTER
	AND sub.id = ss.SUBSCRIPTION_ID

LEFT JOIN SUBSCRIPTION_PRICE SP
ON
sp.SUBSCRIPTION_CENTER = sub.center
AND sp.SUBSCRIPTION_ID = sub.id

	
LEFT JOIN PRODUCTS prod
ON
    st.CENTER = prod.CENTER
    AND st.ID = prod.ID
LEFT JOIN CENTERS cen
ON
	sub.OWNER_CENTER = cen.ID
LEFT JOIN PERSONS p
ON
	sub.OWNER_CENTER = p.CENTER
	AND sub.OWNER_ID = p.ID
-----------------------------------------------------------------	
-- persontype at the time choosen
-- added by MB
LEFT JOIN STATE_CHANGE_LOG scl_ptype
ON
    sub.OWNER_CENTER = scl_ptype.CENTER
    AND sub.OWNER_ID = scl_ptype.ID
    AND scl_ptype.ENTRY_TYPE = 3
    AND longToDate(scl_ptype.ENTRY_START_TIME) <= (:MemberBaseDate +1) -- Date
    AND
        (scl_ptype.ENTRY_END_TIME IS NULL
        OR longToDate(scl_ptype.ENTRY_END_TIME) > (:MemberBaseDate +1))
-----------------------------------------------------------------

LEFT JOIN PERSONS scl_ptype
ON
    sub.OWNER_CENTER = scl_ptype.CENTER
    AND sub.OWNER_ID = scl_ptype.ID

-----------------------------------------------------------------	
WHERE
	sub.OWNER_CENTER IN (:ChosenScope)
	------------------	
	/* only include subscriptions active on date */
	AND sub.START_DATE <= :MemberBaseDate -- Date
	AND
		(sub.END_DATE IS NULL
		OR sub.END_DATE >= :MemberBaseDate) -- Date

	AND sp.from_date <= :MemberBaseDate -- Date
	
	AND
		(sp.to_date IS NULL
		OR sp.to_date >= :MemberBaseDate)
		
		
		

	-------------------
	AND longToDate(sub.CREATION_TIME) < TRUNC(:MemberBaseDate + 1)  -- make sure we dont include sales with start date in past
	/* cannot filter on active on frozen since active on last day means an ended subscription in window when the query is actually running */
	--AND sub.STATE IN (2, 4) -- only include subscriptions that are active or frozen
AND sp.CANCELLED = 0
	AND scl_ptype.PERSONTYPE != 2 -- exclude staff
	--AND prod.PRIMARY_PRODUCT_GROUP_ID IN (7, 8, 9, 10, 11, 12, 218, 219, 221, 222)
	-- Product groups
	-- 7-9 = EFT Subscriptions, 10-12 = CASH subscriptions, 
	-- 218+222 = EFT campaign subscriptions, 219+221 = CASH campaign subscriptions
	-- 18 = add-on subscriptions, 624 = Lifestyle, 826 = Excluded
ORDER BY
	cen.COUNTRY,
	cen.EXTERNAL_ID	