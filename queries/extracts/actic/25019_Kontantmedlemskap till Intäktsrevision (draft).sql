-- The extract is extracted from Exerp on 2026-02-08
--  

SELECT
----------------------------------------------------------------
	cen.ID 											AS CenterId,
	sub.OWNER_CENTER || 'p' || sub.OWNER_ID 		AS PersonId,
	per.fullname,
	per.ssn,

    DECODE (per.PERSONTYPE, 0,'PRIVATE', 1,'STUDENT', 2,'STAFF', 3,'FRIEND', 4,'CORPORATE', 5,'ONEMANCORPORATE', 6,'FAMILY', 7,'SENIOR', 8,'GUEST', 9,'CONTACT', 'UNKNOWN') AS PERSONTYPE,


	sub.CENTER || 'ss' || sub.ID					AS SubscriptionId,
    DECODE (sub.STATE, 2,'ACTIVE', 3,'ENDED', 4,'FROZEN', 7,'WINDOW', 8,'CREATED','UNKNOWN') AS subscription_STATE,
    DECODE (sub.SUB_STATE, 1,'NONE', 2,'AWAITING_ACTIVATION', 3,'UPGRADED', 4,'DOWNGRADED', 5,'EXTENDED', 6, 'TRANSFERRED',7,'REGRETTED',8,'CANCELLED',9,'BLOCKED','UNKNOWN')  AS SUBSCRIPTION_SUB_STATE,
    DECODE(st.ST_TYPE, 0, 'CASH', 1, 'EFT', 'UKNOWN') as PaymentType,

	--company.LASTNAME 								AS Company_Name,
	--CA.NAME 										AS AGREEMENT_NAME,


--	TO_CHAR(longToDate(sub.CREATION_TIME), 'YYYY-MM-DD') AS Sales_Date,
--	TO_CHAR(sub.START_DATE, 'YYYY-MM-DD') 			AS start_DATE,	
--	TO_CHAR(sub.BINDING_END_DATE, 'YYYY-MM-DD') 	AS binding_END_DATE,
--	TO_CHAR(sub.END_DATE, 'YYYY-MM-DD')				AS end_DATE,
	sub.START_DATE 			AS start_DATE,	
	sub.BINDING_END_DATE 	AS binding_END_DATE,
	sub.END_DATE				AS end_DATE,
		--ss.PRICE_NEW AS JoiningOriginal,
	--ss.PRICE_NEW_SPONSORED AS JoiningSponsored,
	--ss.PRICE_NEW_DISCOUNT AS JoiningRebate,

	--sub.binding_price,
	--Sp.price as First_price,
	SUB.SUBSCRIPTION_PRICE,
	--prod.price as OrginalPrice,

	--ss.PRICE_INITIAL_SPONSORED AS InitialSponsored,
	--ss.PRICE_INITIAL_DISCOUNT AS InitialRebate,
	--ss.PRICE_PERIOD AS InitialCustomer,
	--sp.FROM_DATE AS First_Price_From,
	--sp.TO_DATE AS First_Price_To,
	prod.GLOBALID AS Global_Id,
	pg.NAME AS ProductGroup
	 --longtodate(sc.CHANGE_TIME) terminationDate
	

	-------------------------------------------------------------

FROM SUBSCRIPTIONS sub

LEFT JOIN SUBSCRIPTION_SALES ss
ON
	sub.CENTER = ss.SUBSCRIPTION_CENTER
	AND sub.ID = ss.SUBSCRIPTION_ID

INNER JOIN SUBSCRIPTIONTYPES st
ON
	sub.SUBSCRIPTIONTYPE_CENTER = st.CENTER
	AND sub.SUBSCRIPTIONTYPE_ID = st.ID
LEFT JOIN SUBSCRIPTIONTYPES st
ON
    st.CENTER = sub.SUBSCRIPTIONTYPE_CENTER
    AND st.ID = sub.SUBSCRIPTIONTYPE_ID

LEFT JOIN SUBSCRIPTION_CHANGE SC
ON
 
        SC.OLD_SUBSCRIPTION_CENTER = Sub.CENTER
        AND SC.OLD_SUBSCRIPTION_ID = Sub.ID
		AND SC.TYPE = 'END_DATE'
		AND SC.CANCEL_TIME IS NULL



        

LEFT JOIN PRODUCTS prod
ON
    st.CENTER = prod.CENTER
    AND st.ID = prod.ID
LEFT JOIN PRODUCT_GROUP pg
ON
	prod.PRIMARY_PRODUCT_GROUP_ID = pg.ID

LEFT JOIN CENTERS cen
ON
	sub.OWNER_CENTER = cen.ID

LEFT JOIN SUBSCRIPTION_PRICE sp
ON
	sub.CENTER = sp.SUBSCRIPTION_CENTER
	AND sub.ID = sp.SUBSCRIPTION_ID

    AND sp.FROM_DATE <= sub.START_DATE
    AND
        (sp.TO_DATE IS NULL
        OR sp.TO_DATE >= sub.START_DATE)

	AND SP.CANCELLED = 0


-----------------------------------------------------------------	

-----------------------------------------------------------------
LEFT JOIN PERSONS per
ON
    sub.OWNER_CENTER = per.CENTER
    AND sub.OWNER_ID = per.ID
-----------------------------------------------------
-- persons linked to company and agreement at the time choosen
-- added by MB
/* remove to see if this generate duplicates due to match on date and not timestamp
LEFT JOIN
	(
		SELECT
			scl_rel.CENTER,
			scl_rel.ID,
			MAX(scl_rel.ENTRY_START_TIME) AS Entry_Start_Time,
			scl_rel.ENTRY_END_TIME,
			companyAgrRel.RELATIVECENTER,
			companyAgrRel.RELATIVEID,
			companyAgrRel.RELATIVESUBID
		FROM STATE_CHANGE_LOG scl_rel
		INNER JOIN RELATIVES companyAgrRel
		ON
			scl_rel.CENTER = companyAgrRel.CENTER
			AND scl_rel.ID = companyAgrRel.ID
			AND scl_rel.SUBID = companyAgrRel.SUBID
			AND companyAgrRel.RTYPE = 3
		WHERE
			scl_rel.ENTRY_TYPE = 4
			AND scl_rel.STATEID != 3
			AND scl_rel.ENTRY_END_TIME IS NOT NULL
		GROUP BY
			scl_rel.CENTER,
			scl_rel.ID,
			scl_rel.ENTRY_END_TIME,
			companyAgrRel.RELATIVECENTER,
			companyAgrRel.RELATIVEID,
			companyAgrRel.RELATIVESUBID
	) compRel
ON
	compRel.CENTER = sub.OWNER_CENTER
    AND compRel.ID= sub.OWNER_ID
    -- AND longToDate(compRel.ENTRY_START_TIME) < (MemberBaseDate +1) -- Date
    AND longToDate(compRel.ENTRY_START_TIME) <= TRUNC(exerpsysdate()) -- Date
    AND
        (compRel.ENTRY_END_TIME IS NULL
        -- OR longToDate(compRel.ENTRY_END_TIME) > MemberBaseDate)
        OR longToDate(compRel.ENTRY_END_TIME) >= TRUNC(exerpsysdate()))
LEFT JOIN COMPANYAGREEMENTS ca
ON
    ca.CENTER = compRel.RELATIVECENTER
    AND ca.ID = compRel.RELATIVEID
    AND ca.SUBID = compRel.RELATIVESUBID

LEFT JOIN PERSONS company
ON
    company.CENTER = ca.CENTER
    AND company.ID = ca.id
    AND company.sex = 'C'
*/
-----------------------------------------------------------------
/* Current company relation at the time extract is running */
LEFT JOIN RELATIVES companyAgrRel
ON
    sub.OWNER_CENTER = companyAgrRel.CENTER
    AND sub.OWNER_ID = companyAgrRel.ID
    AND companyAgrRel.RTYPE = 3
    AND companyAgrRel.STATUS = 1
LEFT JOIN COMPANYAGREEMENTS ca
ON
    ca.CENTER = companyAgrRel.RELATIVECENTER
    AND ca.ID = companyAgrRel.RELATIVEID
    AND ca.SUBID = companyAgrRel.RELATIVESUBID
LEFT JOIN PERSONS company
ON
    company.CENTER = ca.CENTER
    AND company.ID = ca.id
    AND company.sex = 'C'		
-----------------------------------------------------------------	

WHERE
 sub.START_DATE <= date '2017-11-30' -- Date
	AND
		(sub.END_DATE IS NULL
		OR sub.END_DATE >= date '2017-01-01') -- Date
	------------------	

	-------------------
	/* don't include subscriptions with enddate same day or before startdate */
	--AND 
		--(sub.START_DATE < sub.END_DATE
		--OR sub.END_DATE IS NULL)
	-------------------
	--AND longToDate(sub.CREATION_TIME) < TRUNC(exerpsysdate()) -- make sure we dont include sales with start date in past
	/* cannot filter on active on frozen since active on last day means an ended subscription in window when the query is actually running */
	--AND sub.STATE IN (2, 4) -- only include subscriptions that are active or frozen
	--AND per.PERSONTYPE NOT IN 2 -- exclude staff
	AND sub.OWNER_CENTER in (:scope)
	--AND prod.PRIMARY_PRODUCT_GROUP_ID IN (7, 8, 9, 218, 222, 10, 11, 219, 221, 624, 18)
	AND st.ST_TYPE = 0
	-- Product groups
	-- 7-9 = EFT Subscriptions, 10-12 = CASH subscriptions, 
	-- 218+222 = EFT campaign subscriptions, 219+221 = CASH campaign subscriptions
	-- 18 = add-on subscriptions, 624 = Lifestyle, 826 = Excluded
ORDER BY
	cen.COUNTRY,
	cen.EXTERNAL_ID	