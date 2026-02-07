/**
* Creator: Mikael Ahlberg
* Purpose: List members that have dropped of during a given person.
* Published as report to clubmanagers.
*
*/
SELECT 
	sub.OWNER_CENTER || 'p' || sub.OWNER_ID 		AS PersonId,
	p.fullname,
    pea_mobile.txtvalue AS PhoneMobile,
	TO_CHAR(sub.END_DATE, 'YYYY-MM-DD')				AS end_DATE,
	prod.NAME AS Product_Name

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

LEFT JOIN PERSON_EXT_ATTRS pea_mobile
ON
    pea_mobile.PERSONCENTER = p.center
	AND pea_mobile.PERSONID = p.id
	AND pea_mobile.NAME = '_eClub_PhoneSMS'
-----------------------------------------------------------------	
-- persontype at the time of dropoff
-- added by MB
LEFT JOIN STATE_CHANGE_LOG scl_ptype
ON
    sub.OWNER_CENTER = scl_ptype.CENTER
    AND sub.OWNER_ID = scl_ptype.ID
    AND scl_ptype.ENTRY_TYPE = 3
    AND longToDate(scl_ptype.ENTRY_START_TIME) <= (sub.END_DATE)
    AND (scl_ptype.ENTRY_END_TIME IS NULL OR longToDate(scl_ptype.ENTRY_END_TIME) > (sub.END_DATE))
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
    AND compRel.ID = p.ID
    AND longToDate(compRel.ENTRY_START_TIME) <= (sub.END_DATE)
    AND (compRel.ENTRY_END_TIME IS NULL OR longToDate(compRel.ENTRY_END_TIME) > (sub.END_DATE))
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
    AND (scl_sub.ENTRY_END_TIME IS NULL OR longToDate(scl_sub.ENTRY_END_TIME) > (sub.END_DATE + 2))

-----------------------------------------------------------------	

WHERE 
	
	scl_ptype.STATEID != 2 -- changed to historical persontype
	AND prod.PRIMARY_PRODUCT_GROUP_ID IN (7, 8, 9)
	-- Product groups
	-- 7-9 = EFT Subscriptions, 10-12 = CASH subscriptions, 218+222 = EFT campaign subscriptions, 219+221 = CASH campaign subscriptions
	-- 18 = add-on subscriptions, 624 = Lifestyle, 826 = Excluded
	AND p.center in (:Scope)
    AND sub.END_DATE >= cast(:FromDate as date)
   	AND sub.END_DATE < cast(:ToDate as date) + 1
	AND st.ST_TYPE = '0'
	AND sub.SUB_STATE = '1'
