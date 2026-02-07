/* 
 * TOTAL PT EFT SUBSCRIPTIONS BY DATE
 */
-- TODO

SELECT Distinct
----------------------------------------------------------------
	to_char(cast(:MemberBaseDate as date), 'YYYY-MM-DD') AS Datum,
	sub.OWNER_CENTER AS SALES_CENTER,	
	p.CENTER || 'p' || p.iD 		AS PersonId
	

---------------------------------------------------------------- 


FROM SUBSCRIPTIONS sub
--------------------------------------------------------------
-- Subscription price at the time choosen
LEFT JOIN SUBSCRIPTION_PRICE sp
ON
	sp.SUBSCRIPTION_CENTER = sub.CENTER
	AND sp.SUBSCRIPTION_ID = sub.ID
	-- make sure we join the price from actual date
	AND sp.FROM_DATE <= cast(:MemberBaseDate as date) --TRUNC(current_timestamp -1) -- Date, 
	AND
		(sp.TO_DATE IS NULL
		OR sp.TO_DATE >= cast(:MemberBaseDate as date)) --TRUNC(current_timestamp -1)) -- Date
	AND sp.CANCELLED != 1
--------------------------------------------------------------
-- Subscription state at the time choosen
LEFT JOIN STATE_CHANGE_LOG scl_substate
ON
    sub.CENTER = scl_substate.CENTER
    AND sub.ID = scl_substate.ID
    AND scl_substate.ENTRY_TYPE = 2
    AND longToDate(scl_substate.ENTRY_START_TIME) <= (cast(:MemberBaseDate as date) +1) -- Date
    AND
        (scl_substate.ENTRY_END_TIME IS NULL
        OR longToDate(scl_substate.ENTRY_END_TIME) > (cast(:MemberBaseDate as date) +1))
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
    AND longToDate(scl_ptype.ENTRY_START_TIME) <= (cast(:MemberBaseDate as date) +1) -- Date
    AND
        (scl_ptype.ENTRY_END_TIME IS NULL
        OR longToDate(scl_ptype.ENTRY_END_TIME) > (cast(:MemberBaseDate as date) +1))
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
    AND longToDate(compRel.ENTRY_START_TIME) < (cast(:MemberBaseDate as date) +1) -- Date
    AND (compRel.ENTRY_END_TIME IS NULL
        OR longToDate(compRel.ENTRY_END_TIME) > (cast(:MemberBaseDate as date) +1))
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
	AND sub.START_DATE <= cast(:MemberBaseDate as date) -- Date
	AND
		(sub.END_DATE IS NULL
		OR sub.END_DATE >= cast(:MemberBaseDate as date)) -- Date
	AND longToDate(sub.CREATION_TIME) < (cast(:MemberBaseDate as date) + 1) -- make sure we dont include sales with start date in past
	 AND scl_ptype.STATEID != 2 -- exclude staff
	AND scl_substate.STATEID IN (2) -- only include subscriptions that are active or 
	--AND prod.PRIMARY_PRODUCT_GROUP_ID IN (1224, 1227, 1824, 2224, 2225, 2226, 6624, 6625, 6626)
	-- Product groups
	-- 7-9 = EFT Subscriptions, 10-12 = CASH subscriptions, 218+222 = EFT campaign subscriptions, 219+221 = CASH campaign subscriptions
	-- 18 = add-on subscriptions, 624 = Lifestyle, 826 = Excluded, 1224, 1227, 1824, 2224-2226 = Personal Training
