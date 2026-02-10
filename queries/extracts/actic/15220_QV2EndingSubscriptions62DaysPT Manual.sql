-- The extract is extracted from Exerp on 2026-02-08
--  
/* QV2EndingSubscriptions62DaysPT Manual
 *
 * Subscriptions with end_date within 62 days
 */
-- filter on productgroups and includes staff
SELECT
	cen.COUNTRY,
	cen.EXTERNAL_ID 								AS Cost,
	cen.ID 											AS CenterId,
	sub.OWNER_CENTER || 'p' || sub.OWNER_ID 		AS PersonId,
	TO_CHAR(trunc(months_between(TRUNC(:MemberBaseDate), per.birthdate)/12)) AS Age,
    DECODE (scl_ptype.STATEID, 0,'PRIVATE', 1,'STUDENT', 2,'STAFF', 3,'FRIEND', 4,'CORPORATE', 5,'ONEMANCORPORATE', 6,'FAMILY', 7,'SENIOR', 8,'GUEST', 9,'CONTACT', 'UNKNOWN') AS PERSONTYPE,
--    DECODE (per.PERSONTYPE, 0,'PRIVATE', 1,'STUDENT', 2,'STAFF', 3,'FRIEND', 4,'CORPORATE', 5,'ONEMANCORPORATE', 6,'FAMILY', 7,'SENIOR', 8,'GUEST', 9,'CONTACT', 'UNKNOWN') AS PERSONTYPE,
	company.LASTNAME 								AS Company_Name,
	CA.NAME 										AS AGREEMENT_NAME,
	CASE
		WHEN scl_substate.STATEID IS NULL
		THEN DECODE(sub.STATE, 2,'ACTIVE', 3,'ENDED', 4,'FROZEN', 7,'WINDOW', 8,'CREATED','UNKNOWN')
		ELSE DECODE(scl_substate.STATEID, 2,'ACTIVE', 3,'ENDED', 4,'FROZEN', 7,'WINDOW', 8,'CREATED','UNKNOWN')
	END AS subscription_STATE,
	CASE
		WHEN scl_substate.SUB_STATE IS NULL 
		THEN DECODE(sub.SUB_STATE, 1,'NONE', 2,'AWAITING_ACTIVATION', 3,'UPGRADED', 4,'DOWNGRADED', 5,'EXTENDED', 6, 'TRANSFERRED',7,'REGRETTED',8,'CANCELLED',9,'BLOCKED','UNKNOWN')
		ELSE DECODE(scl_substate.SUB_STATE, 1,'NONE', 2,'AWAITING_ACTIVATION', 3,'UPGRADED', 4,'DOWNGRADED', 5,'EXTENDED', 6, 'TRANSFERRED',7,'REGRETTED',8,'CANCELLED',9,'BLOCKED','UNKNOWN')
	END AS SUBSCRIPTION_SUB_STATE,
	DECODE (st.ST_TYPE, 0,'CASH', 1,'EFT') 			AS PaymentType,
	TO_CHAR(sub.START_DATE, 'YYYY-MM-DD') 			AS start_DATE,	
	TO_CHAR(sub.BINDING_END_DATE, 'YYYY-MM-DD') 	AS binding_END_DATE,
	TO_CHAR(sub.END_DATE, 'YYYY-MM-DD')				AS end_DATE,
	TO_CHAR(sub.END_DATE, 'YYYY-MM-DD')				AS Last_active_day,
	TO_CHAR(sub.END_DATE + 1, 'YYYY-MM-DD')				AS real_end_DATE,
	sub.BINDING_PRICE,
	sub.EXTENDED_TO_CENTER,
	sub.CENTER || 'ss' || sub.ID					AS SubscriptionId,
	prod.NAME AS Product_Name,
	prod.GLOBALID AS Global_Id,
	pg.NAME AS PRODUCT_Group
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

LEFT JOIN PERSONS per
ON
	sub.OWNER_CENTER = per.CENTER
	AND sub.OWNER_ID = per.ID
LEFT JOIN CENTERS cen
ON
	sub.OWNER_CENTER = cen.ID
--------------------------------------------------------------
-- Subscription state at the time choosen
LEFT JOIN STATE_CHANGE_LOG scl_substate
ON
    sub.CENTER = scl_substate.CENTER
    AND sub.ID = scl_substate.ID
    AND scl_substate.ENTRY_TYPE = 2
    AND longToDate(scl_substate.ENTRY_START_TIME) <= (:MemberBaseDate +2) -- Date
    AND
        (scl_substate.ENTRY_END_TIME IS NULL
        OR longToDate(scl_substate.ENTRY_END_TIME) > (:MemberBaseDate +2))
--------------------------------------------------------------

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
	sub.CENTER IN (:ChosenScope)
	--AND sub.END_DATE >= TRUNC(exerpsysdate())
	--AND sub.END_DATE < TRUNC(exerpsysdate() + 62)
	AND sub.END_DATE >= (:MemberBaseDate + 1)
	AND sub.END_DATE < (:MemberBaseDate + 1 + 62)
	-- AND per.PERSONTYPE != 2 --including staff
	-------------------
	/* don't include subscriptions with enddate same day or before startdate */
	AND 
		(sub.START_DATE < sub.END_DATE
		OR sub.END_DATE IS NULL)
	-------------------
	-- AND sub.STATE IN(2, 4) -- only include active or frozen
	AND prod.PRIMARY_PRODUCT_GROUP_ID IN (1224, 1227, 1824, 2224, 2225, 2226, 6624, 6625, 6626, 10224, 10225, 10226, 10825, 3224, 3625, 5224, 5227)
	-- Product groups
	-- 7-9 = EFT Subscriptions, 10-12 = CASH subscriptions, 218+222 = EFT campaign subscriptions, 219+221 = CASH campaign subscriptions
	-- 18 = add-on subscriptions, 624 = Lifestyle, 826 = Excluded, 1224, 1227, 1824, 2224-2226 = Personal Training
ORDER BY
	sub.END_DATE