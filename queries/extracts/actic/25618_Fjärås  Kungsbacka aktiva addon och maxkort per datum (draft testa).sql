-- The extract is extracted from Exerp on 2026-02-08
-- Visar endsast medlemskap som innehåller namet orden "max" och "add"
/* 
 * TOTAL PT EFT SUBSCRIPTIONS BY DATE
 */
-- TODO

SELECT
----------------------------------------------------------------
    cen.COUNTRY,
	cen.EXTERNAL_ID 								AS Cost,
	cen.ID 											AS CenterId,
	sub.OWNER_CENTER || 'p' || sub.OWNER_ID 		AS PersonId,
	TO_CHAR(TRUNC(MONTHS_BETWEEN(:MemberBaseDate, p.BIRTHDATE)/12)) AS Age,
	p.SEX AS Gender,
    DECODE (scl_ptype.STATEID, 0,'PRIVATE', 1,'STUDENT', 2,'STAFF', 3,'FRIEND', 4,'CORPORATE', 5,'ONEMANCORPORATE', 6,'FAMILY', 7,'SENIOR', 8,'GUEST', 9,'CONTACT', 'UNKNOWN') AS "PERSONTYPE",
	company.LASTNAME 								AS Company_Name,
	CA.NAME 										AS AGREEMENT_NAME,
	0 AS Joiningfee,
--	sub.BINDING_PRICE AS MONTHLY_PRICE, -- price at sales date, don't reflect pricechange i.e campaigns
--	sp.PRICE AS Monthly_Price, -- is null if there is no price changes 
	CASE
		WHEN sp.PRICE IS NULL
		THEN sub.BINDING_PRICE
		ELSE sp.PRICE
	END Monthly_Price,
	CASE
		WHEN sp.TYPE IS NULL
		THEN 'BINDING PRICE'
		ELSE sp.TYPE
	END Price_Type,
	sub.CENTER || 'ss' || sub.ID					AS SubscriptionId,
    DECODE (sub.STATE, 2,'ACTIVE', 3,'ENDED', 4,'FROZEN', 7,'WINDOW', 8,'CREATED','UNKNOWN') AS subscription_STATE,
    DECODE (scl_substate.STATEID, 2,'ACTIVE', 3,'ENDED', 4,'FROZEN', 7,'WINDOW', 8,'CREATED','UNKNOWN') AS sub_STATE,
    DECODE (sub.SUB_STATE, 1,'NONE', 2,'AWAITING_ACTIVATION', 3,'UPGRADED', 4,'DOWNGRADED', 5,'EXTENDED', 6, 'TRANSFERRED',7,'REGRETTED',8,'CANCELLED',9,'BLOCKED','UNKNOWN')  AS SUBSCRIPTION_SUB_STATE,
    DECODE (scl_substate.SUB_STATE, 1,'NONE', 2,'AWAITING_ACTIVATION', 3,'UPGRADED', 4,'DOWNGRADED', 5,'EXTENDED', 6, 'TRANSFERRED',7,'REGRETTED',8,'CANCELLED',9,'BLOCKED','UNKNOWN')  AS SUB_SUB_STATE,
    DECODE(st.ST_TYPE, 0, 'CASH', 1, 'EFT', 'UKNOWN') as PaymentType,
	longToDate(sub.CREATION_TIME) AS Sales_Date,
	sub.START_DATE 			AS "start_DATE",	
	sub.BINDING_END_DATE 	AS "binding_END_DATE",
	sub.END_DATE				AS "end_DATE",
	prod.NAME AS Product_Name,
	prod.GLOBALID AS Global_Id

FROM SUBSCRIPTIONS sub
--------------------------------------------------------------
-- Subscription price at the time choosen
LEFT JOIN SUBSCRIPTION_PRICE sp
ON
	sp.SUBSCRIPTION_CENTER = sub.CENTER
	AND sp.SUBSCRIPTION_ID = sub.ID
	-- make sure we join the price from actual date
	AND sp.FROM_DATE <= :MemberBaseDate --TRUNC(exerpsysdate() -1) -- Date, 
	AND
		(sp.TO_DATE IS NULL
		OR sp.TO_DATE >= :MemberBaseDate) --TRUNC(exerpsysdate() -1)) -- Date
	AND sp.CANCELLED != 1
--------------------------------------------------------------
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
--------------------------------------------------------------
LEFT JOIN SUBSCRIPTIONTYPES st
ON
    st.CENTER = sub.SUBSCRIPTIONTYPE_CENTER
    AND st.ID = sub.SUBSCRIPTIONTYPE_ID
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

(prod.name Like '%Max%' OR

prod.name Like '%max%' OR

prod.name Like '%Add%' OR

prod.name Like 'add%')

	AND sub.OWNER_CENTER IN (:Scope)
	AND sub.START_DATE <= :MemberBaseDate -- Date
	AND
		(sub.END_DATE IS NULL
		OR sub.END_DATE >= :MemberBaseDate) -- Date
	AND longToDate(sub.CREATION_TIME) < (:MemberBaseDate + 1) -- make sure we dont include sales with start date in past
	 AND scl_ptype.STATEID != 2 -- exclude staff
	AND scl_substate.STATEID IN (2) -- only include subscriptions that are active or 
	--AND prod.PRIMARY_PRODUCT_GROUP_ID IN (7, 8, 9, 10, 11, 12, 218, 219, 221, 222)

-- Product groups
	-- 7-9 = EFT Subscriptions, 10-12 = CASH subscriptions, 
	-- 218+222 = EFT campaign subscriptions, 219+221 = CASH campaign subscriptions
	-- 18 = add-on subscriptions, 624 = Lifestyle, 826 = Excluded


