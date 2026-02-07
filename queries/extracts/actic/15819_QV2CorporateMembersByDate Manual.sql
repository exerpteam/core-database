/* 
 * TOTAL CORPORATE MEMBERS BY DATE
 * Used for total corporate members.
 *
 */
-- TODO
-- 

SELECT
----------------------------------------------------------------
    cen.COUNTRY,
	cen.EXTERNAL_ID 								AS Cost,
	cen.ID 											AS CenterId,
	sub.OWNER_CENTER || 'p' || sub.OWNER_ID 		AS PersonId,
/* TODO old persontype from Transfer.
need to look in old pids state_change_log or persons table is easier
	CASE
		WHEN scl_ptype.STATEID IS NULL
		THEN 
	END PersonType,
*/
	TO_CHAR(TRUNC(MONTHS_BETWEEN(:MemberBaseDate, p.BIRTHDATE)/12)) AS Age,
	DECODE (scl_ptype.STATEID, 0,'PRIVATE', 1,'STUDENT', 2,'STAFF', 3,'FRIEND', 4,'CORPORATE', 5,'ONEMANCORPORATE', 6,'FAMILY', 7,'SENIOR', 8,'GUEST', 9,'CONTACT', 'UNKNOWN') AS Current_PTYPE,
	company.LASTNAME 								AS Company_Name,
	CA.NAME 										AS AGREEMENT_NAME,
	0 AS Joiningfee,
	0 AS MONTHLY_PRICE,
	sub.CENTER || 'ss' || sub.ID					AS SubscriptionId,
    DECODE (scl_substate.STATEID, 2,'ACTIVE', 3,'ENDED', 4,'FROZEN', 7,'WINDOW', 8,'CREATED','UNKNOWN') AS sub_STATE,
    DECODE (scl_substate.SUB_STATE, 1,'NONE', 2,'AWAITING_ACTIVATION', 3,'UPGRADED', 4,'DOWNGRADED', 5,'EXTENDED', 6, 'TRANSFERRED',7,'REGRETTED',8,'CANCELLED',9,'BLOCKED','UNKNOWN')  AS SUB_SUB_STATE,
    DECODE(st.ST_TYPE, 0, 'CASH', 1, 'EFT', 'UKNOWN') as PaymentType,

	ss.PRICE_NEW AS JoiningOriginal,
	ss.PRICE_NEW_SPONSORED AS JoiningSponsored,
	ss.PRICE_NEW_DISCOUNT AS JoiningRebate,
	ss.PRICE_INITIAL AS InitialOriginal,
	ss.PRICE_INITIAL_SPONSORED AS InitialSponsored,
	ss.PRICE_INITIAL_DISCOUNT AS InitialRebate,
	ss.PRICE_PERIOD AS InitialCustomer,
	CASE
		WHEN ss.SUBSCRIPTION_TYPE_TYPE = 0 THEN ceil(( ss.PRICE_PERIOD /( ( ss.END_DATE - ss.START_DATE)-2) )*30) -- cash pr month
		WHEN ss.SUBSCRIPTION_TYPE_TYPE = 1 THEN ss.PRICE_PERIOD
	END   AS MonthlyPrice,
	sp.PRICE AS SP_PRICE,
	sp.TYPE AS SP_TYPE,	
	longToDate(sub.CREATION_TIME) AS Sales_Date,
	sub.START_DATE 			AS start_DATE,	
	sub.BINDING_END_DATE 	AS binding_END_DATE,
	sub.END_DATE				AS end_DATE,
	sub.BINDING_PRICE,
	prod.NAME AS Product_Name,
	prod.GLOBALID AS Global_Id,
	pg.NAME AS Product_Group

FROM SUBSCRIPTIONS sub

LEFT JOIN SUBSCRIPTION_SALES ss
ON
	sub.CENTER = ss.SUBSCRIPTION_CENTER
	AND sub.ID = ss.SUBSCRIPTION_ID
	
LEFT JOIN SUBSCRIPTION_PRICE sp
ON
	sub.CENTER = sp.SUBSCRIPTION_CENTER
	AND sub.ID = sp.SUBSCRIPTION_ID
    AND sp.FROM_DATE <= sub.START_DATE
    AND
        (sp.TO_DATE IS NULL
        OR sp.TO_DATE >= sub.START_DATE)
	AND SP.CANCELLED = 0

INNER JOIN SUBSCRIPTIONTYPES st
ON
	sub.SUBSCRIPTIONTYPE_CENTER = st.CENTER
	AND sub.SUBSCRIPTIONTYPE_ID = st.ID
LEFT JOIN SUBSCRIPTIONTYPES st
ON
    st.CENTER = sub.SUBSCRIPTIONTYPE_CENTER
    AND st.ID = sub.SUBSCRIPTIONTYPE_ID
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
-- Subscription state at the time choosen
LEFT JOIN STATE_CHANGE_LOG scl_substate
ON
    sub.CENTER = scl_substate.CENTER
    AND sub.ID = scl_substate.ID
    AND scl_substate.ENTRY_TYPE = 2
    AND longToDate(scl_substate.ENTRY_START_TIME) <= (:MemberBaseDate +1) -- Date
    AND
        (scl_substate.ENTRY_END_TIME IS NULL
        OR longToDate(scl_substate.ENTRY_END_TIME) > (:MemberBaseDate +1))
-----------------------------------------------------------------	
-- persons linked to company and agreement at the time choosen
-- added by MB
LEFT JOIN
	(
		SELECT
			scl_rel.CENTER,
			scl_rel.ID,
			scl_rel.ENTRY_START_TIME,
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
	) compRel
ON
	compRel.CENTER = sub.OWNER_CENTER
    AND compRel.ID= sub.OWNER_ID
    AND longToDate(compRel.ENTRY_START_TIME) < (:MemberBaseDate +1) -- Date
    AND (compRel.ENTRY_END_TIME IS NULL
        OR longToDate(compRel.ENTRY_END_TIME) > (:MemberBaseDate +1))
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
-----------------------------------------------------------------	

WHERE
	sub.OWNER_CENTER IN (:ChosenScope)
	------------------	
	/* only include subscriptions active on date */
	AND sub.START_DATE <= :MemberBaseDate -- Date
	AND
		(sub.END_DATE IS NULL
		OR sub.END_DATE >= :MemberBaseDate) -- Date
	-------------------
	/* don't include subscriptions with enddate same day or before startdate */
	AND
		(sub.START_DATE < sub.END_DATE
		OR sub.END_DATE IS NULL)
	-------------------
	AND longToDate(sub.CREATION_TIME) < (:MemberBaseDate + 1) -- make sure we dont include sales with start date in past
	-- AND scl_ptype.STATEID = 4 -- only include historical corporate members
	AND scl_ptype.STATEID = 4 -- only include corporate members
	/* cannot filter on active on frozen since active on last day means an ended subscription in window when the query is actually running */
	-- AND sub.STATE IN (2, 4) -- only include subscriptions that are active or frozen
	AND prod.PRIMARY_PRODUCT_GROUP_ID IN (7, 8, 9, 10, 11, 12, 218, 219, 221, 222)
	-- Product groups
	-- 7-9 = EFT Subscriptions, 10-12 = CASH subscriptions, 218+222 = EFT campaign subscriptions, 219+221 = CASH campaign subscriptions
	-- 18 = add-on subscriptions, 624 = Lifestyle, 826 = Excluded