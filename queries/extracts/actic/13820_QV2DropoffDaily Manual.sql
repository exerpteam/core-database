/*
 * Dropoff daily used for churn KPI.
 * EFT uses enddate and for CASH we use subscription enddate + window  
 * days to actually calculate it as a dropoff
 */
-- TODO
SELECT 
    cen.COUNTRY,
	cen.EXTERNAL_ID 								AS Cost,
	cen.ID 											AS CenterId,
	sub.OWNER_CENTER || 'p' || sub.OWNER_ID 		AS PersonId,
	TO_CHAR(trunc(months_between(sub.END_DATE + 1, p.birthdate)/12)) AS Age,
    DECODE (scl_ptype.STATEID, 0,'PRIVATE', 1,'STUDENT', 2,'STAFF', 3,'FRIEND', 4,'CORPORATE', 5,'ONEMANCORPORATE', 6,'FAMILY', 7,'SENIOR', 8,'GUEST', 9,'CONTACT', 'UNKNOWN') AS PERSONTYPE,
	company.LASTNAME 								AS Company_Name,
	CA.NAME 										AS AGREEMENT_NAME,
	sub.CENTER || 'ss' || sub.ID					AS SubscriptionId,
	DECODE (scl_sub.STATEID, 2,'ACTIVE', 3,'ENDED', 4,'FROZEN', 7,'WINDOW', 8,'CREATED','UNKNOWN') AS sub_STATE,
	DECODE (scl_sub.SUB_STATE, 1,'NONE', 2,'AWAITING_ACTIVATION', 3,'UPGRADED', 4,'DOWNGRADED', 5,'EXTENDED', 6, 'TRANSFERRED',7,'REGRETTED',8,'CANCELLED',9,'BLOCKED','UNKNOWN')  AS SUB_SUB_STATE,
--  DECODE (sub.STATE, 2,'ACTIVE', 3,'ENDED', 4,'FROZEN', 7,'WINDOW', 8,'CREATED','UNKNOWN') AS subscription_STATE,
--	DECODE (sub.SUB_STATE, 1,'NONE', 2,'AWAITING_ACTIVATION', 3,'UPGRADED', 4,'DOWNGRADED', 5,'EXTENDED', 6, 'TRANSFERRED',7,'REGRETTED',8,'CANCELLED',9,'BLOCKED','UNKNOWN')  AS SUBSCRIPTION_SUB_STATE,
    DECODE(st.ST_TYPE, 0, 'CASH', 1, 'EFT', 'UKNOWN') as PaymentType,
	TO_CHAR(sub.START_DATE, 'YYYY-MM-DD') 			AS start_DATE,	
	TO_CHAR(sub.BINDING_END_DATE, 'YYYY-MM-DD') 	AS binding_END_DATE,
	TO_CHAR(sub.END_DATE, 'YYYY-MM-DD')				AS end_DATE,
	CASE
			WHEN st.ST_TYPE = 1 THEN TO_CHAR(sub.END_DATE + 1, 'YYYY-MM-DD')
			WHEN st.ST_TYPE = 0 THEN TO_CHAR(sub.END_DATE + 1 + 30, 'YYYY-MM-DD')
	END churn_end_date,
	sub.BINDING_PRICE,
	sub.EXTENDED_TO_CENTER,
	prod.NAME AS Product_Name,
	prod.GLOBALID AS Global_Id,
	pg.NAME AS ProductGroup	

FROM 
	SUBSCRIPTIONS sub
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
-- persontype at the time of dropoff
-- added by MB
LEFT JOIN STATE_CHANGE_LOG scl_ptype
ON
    sub.OWNER_CENTER = scl_ptype.CENTER
    AND sub.OWNER_ID = scl_ptype.ID
    AND scl_ptype.ENTRY_TYPE = 3
    AND longToDate(scl_ptype.ENTRY_START_TIME) <= (sub.END_DATE)
    AND
        (scl_ptype.ENTRY_END_TIME IS NULL
        OR longToDate(scl_ptype.ENTRY_END_TIME) > (sub.END_DATE))
-----------------------------------------------------------------	
-- persons linked to company and agreement at the time of dropoff
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
	compRel.CENTER = p.CENTER
    AND compRel.ID= p.ID
    AND longToDate(compRel.ENTRY_START_TIME) <= (sub.END_DATE)
    AND
        (compRel.ENTRY_END_TIME IS NULL
        OR longToDate(compRel.ENTRY_END_TIME) > (sub.END_DATE))
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
-- subscriptionstatus at the time of dropoff
-- added by MB

LEFT JOIN STATE_CHANGE_LOG scl_sub
ON
    sub.CENTER = scl_sub.CENTER
    AND sub.ID = scl_sub.ID
    AND scl_sub.ENTRY_TYPE = 2
    AND longToDate(scl_sub.ENTRY_START_TIME) <= (sub.END_DATE + 2)
    AND
        (scl_sub.ENTRY_END_TIME IS NULL
        OR longToDate(scl_sub.ENTRY_END_TIME) > (sub.END_DATE + 2))

-----------------------------------------------------------------	

WHERE 
	sub.CENTER IN (:ChosenScope)
	AND scl_ptype.STATEID != 2 -- changed to historical persontype
	AND prod.PRIMARY_PRODUCT_GROUP_ID IN (7, 8, 9, 10, 11, 12, 218, 219, 221, 222)
	-- Product groups
	-- 7-9 = EFT Subscriptions, 10-12 = CASH subscriptions, 218+222 = EFT campaign subscriptions, 219+221 = CASH campaign subscriptions
	-- 18 = add-on subscriptions, 624 = Lifestyle, 826 = Excluded

	AND sub.END_DATE BETWEEN 
		CASE
			WHEN st.ST_TYPE = 1 THEN (:MemberBaseDate - 1) 		-- eft
			WHEN st.ST_TYPE = 0 THEN (:MemberBaseDate - 1 - 30) -- cash
		END 
		
		AND
		CASE
			WHEN st.ST_TYPE = 1 THEN (:MemberBaseDate - 1)
			WHEN st.ST_TYPE = 0 THEN (:MemberBaseDate - 1 - 30)
		END
	AND sub.SUB_STATE !=
		CASE
			WHEN st.ST_TYPE = 1 THEN 99
			WHEN st.ST_TYPE = 0 THEN 5
		END
