-- The extract is extracted from Exerp on 2026-02-08
-- 'MYACTIC_7DAYS', '10_DAYS_FREE_TRAINING', '10_DAGAR_TRANING', 'CASH_1_M_CAMPAIGN_COMPANY', 'CASH_14_DAYS', 'CASH_10_DAYS_CAMPAIGN')
SELECT 
	sub.OWNER_CENTER || 'p' || sub.OWNER_ID 		AS PersonId,
	DECODE (p.STATUS, 0,'LEAD', 1,'ACTIVE', 2,'INACTIVE', 3,'TEMPORARYINACTIVE', 4,'TRANSFERED', 5,'DUPLICATE', 6,'PROSPECT', 7,'DELETED','UNKNOWN') AS STATUS,
	p.fullname,
    pea_mobile.txtvalue AS PhoneMobile,
	--TO_CHAR(trunc(months_between(sub.END_DATE + 1, p.birthdate)/12)) AS Age,
  --  DECODE (scl_ptype.STATEID, 0,'PRIVATE', 1,'STUDENT', 2,'STAFF', 3,'FRIEND', 4,'CORPORATE', 5,'ONEMANCORPORATE', 6,'FAMILY', 7,'SENIOR', 8,'GUEST', 9,'CONTACT', 'UNKNOWN') AS PERSONTYPE,
	--company.LASTNAME 								AS Company_Name,
	--CA.NAME 										AS AGREEMENT_NAME,
		--DECODE (scl_sub.STATEID, 2,'ACTIVE', 3,'ENDED', 4,'FROZEN', 7,'WINDOW', 8,'CREATED','UNKNOWN') AS sub_STATE,
	--DECODE (scl_sub.SUB_STATE, 1,'NONE', 2,'AWAITING_ACTIVATION', 3,'UPGRADED', 4,'DOWNGRADED', 5,'EXTENDED', 6, 'TRANSFERRED',7,'REGRETTED',8,'CANCELLED',9,'BLOCKED','UNKNOWN')  AS SUB_SUB_STATE,
   -- DECODE(st.ST_TYPE, 0, 'CASH', 1, 'EFT', 'UKNOWN') as PaymentType,
	--TO_CHAR(sub.START_DATE, 'YYYY-MM-DD') 			AS start_DATE,	
	--TO_CHAR(sub.BINDING_END_DATE, 'YYYY-MM-DD') 	AS binding_END_DATE,
	TO_CHAR(sub.END_DATE, 'YYYY-MM-DD')				AS end_DATE,

	--sub.BINDING_PRICE,
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
	
	scl_ptype.STATEID != 2 -- changed to historical persontype
	
	AND prod.GLOBALID IN ('MYACTIC_7DAYS', '10_DAYS_FREE_TRAINING', '10_DAGAR_TRANING', 'CASH_1_M_CAMPAIGN_COMPANY', 'CASH_14_DAYS', 'CASH_10_DAYS_CAMPAIGN')
	AND p.STATUS = 2
	AND sub.END_DATE = TRUNC(exerpsysdate() - 1)
	AND p.center IN (:Scope)
	







