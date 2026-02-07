/* Visits Daily Manual */
SELECT
	cen.COUNTRY,
	cen.EXTERNAL_ID 												AS Cost,
	cil.CENTER || 'p' || cil.ID 									AS PersonKey,
	per.FIRSTNAME || ' ' || per.LASTNAME 							AS PersonName,
    DECODE (scl_ptype.STATEID, 0,'PRIVATE', 1,'STUDENT', 2,'STAFF', 3,'FRIEND', 4,'CORPORATE', 5,'ONEMANCORPORATE', 6,'FAMILY', 7,'SENIOR', 8,'GUEST', 9,'CONTACT', 'UNKNOWN') AS PERSONTYPE,
	DECODE (scl_pstatus.STATEID, 0,'LEAD', 1,'ACTIVE', 2,'INACTIVE', 3,'TEMPORARY INACTIVE', 4,'TRANSFERED', 5,'DUPLICATE', 6, 'PROSPECT',7,'DELETED',9,'CONTACT', 'UNKNOWN')  AS PERSONSTATUS, -- changed 2015-04-18
	TO_CHAR(TRUNC(MONTHS_BETWEEN(:MemberBaseDate, per.BIRTHDATE)/12)) AS Age,
	per.SEX AS Gender, -- add 2015-02-18
	CASE
		WHEN newsub.CENTER IS NOT NULL THEN newsub.CENTER || 'ss' || newsub.ID
		ELSE NULL
	END																AS SubscriptionId,
    DECODE(newsub.ST_TYPE, 0, 'CASH', 1, 'EFT')			 			AS PaymentType,
	CASE
		WHEN compRel.RELATIVECENTER IS NOT NULL THEN compRel.RELATIVECENTER || 'p' || compRel.RELATIVEID
		ELSE NULL
	END 															AS Company,
    COMPANY.LASTNAME                   								AS COMPANY_NAME,
	CASE
		WHEN compRel.RELATIVECENTER  IS NOT NULL THEN CA.NAME
		ELSE NULL
	END 															AS CA_COMPANY_AGREEMENT_NAME,
	
	TO_CHAR(longToDate(cil.CHECKIN_TIME), 'Day') 					AS Weekday,
	TO_CHAR(longToDate(cil.CHECKIN_TIME), 'YYYY-MM-DD')				AS CheckinDate,
	TO_CHAR(TRUNC(longToDate(cil.CHECKIN_TIME), 'HH'), 'HH24') || ' - ' || TO_CHAR(TRUNC(longToDate(cil.CHECKIN_TIME), 'HH') + 1/24, 'HH24') AS Hour,
	CASE
		WHEN cil.CENTER = cil.CHECKIN_CENTER
		THEN 1
		ELSE NULL
	END 															AS LocalVisits,
	CASE
		WHEN cil.CENTER != cil.CHECKIN_CENTER
		THEN 1
		ELSE NULL
	END 															AS GuestVisits,
	1 																AS Visits,
	CASE
		WHEN br.NAME IS NOT NULL THEN BR.NAME
		WHEN act.NAME IS NOT NULL THEN act.NAME
		ELSE 'NONE'
	END 															AS CheckinReason,
	TO_CHAR(longToDate(cil.CHECKIN_TIME), 'YYYY-MM-DD HH24:MI')		AS PersonTime
	
FROM
	CHECKIN_LOG cil

LEFT JOIN CENTERS cen
ON
	cil.CHECKIN_CENTER = cen.ID
LEFT JOIN PERSONS per
ON
	cil.CENTER = per.CENTER
	AND cil.ID = per.ID
----------------------------------------------------------------
-- Checkin reason (Attend/Class)

LEFT JOIN ATTENDS att
ON	
	att.PERSON_CENTER = cil.CENTER
	AND att.PERSON_ID = cil.ID
	AND (att.START_TIME - cil.CHECKIN_TIME) BETWEEN -60000 AND 60000 --one minute +- between checkin and attend is allowed
LEFT JOIN BOOKING_RESOURCES br
ON
	att.BOOKING_RESOURCE_CENTER = br.CENTER
	AND att.BOOKING_RESOURCE_ID = br.ID
LEFT JOIN PARTICIPATIONS par
ON	
	par.PARTICIPANT_CENTER = cil.CENTER
	AND par.PARTICIPANT_ID = cil.ID
	AND (par.SHOWUP_TIME - cil.CHECKIN_TIME) BETWEEN -60000 AND 60000 --one minute +- between checkin and class participation is allowed
LEFT JOIN BOOKINGS bk
ON
	bk.CENTER = par.BOOKING_CENTER
	AND bk.ID = par.BOOKING_ID
LEFT JOIN ACTIVITY act
ON
    bk.ACTIVITY = act.ID
----------------------------------------------------------------
-- Current subscription at the time choosen
-- added by MB
LEFT JOIN 
	(
		SELECT
			sub.CENTER,
			sub.ID,
			sub.OWNER_CENTER,
			sub.OWNER_ID,
			st.ST_TYPE
		FROM SUBSCRIPTIONS sub
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
		WHERE
			prod.PRIMARY_PRODUCT_GROUP_ID IN (7, 8, 9, 10, 11, 12, 218, 219, 221, 222)
			-- Product groups
			-- 7-9 = EFT Subscriptions, 10-12 = CASH subscriptions, 218+222 = EFT campaign subscriptions, 219+221 = CASH campaign subscriptions
			-- 18 = add-on subscriptions, 624 = Lifestyle, 826 = Excluded
			AND sub.START_DATE <= :MemberBaseDate -- Date
			AND
				(sub.END_DATE IS NULL
				OR sub.END_DATE >= :MemberBaseDate) -- Date
			--AND sub.START_DATE <= TRUNC(exerpsysdate() -1) -- Date
			--AND
			--	(sub.END_DATE IS NULL
			--	OR sub.END_DATE >= TRUNC(exerpsysdate() -1)) -- Date
	) newsub
ON
	cil.CENTER = newsub.OWNER_CENTER
	AND cil.ID = newsub.OWNER_ID
	
-----------------------------------------------------------------	
-- persontype at the time choosen
-- added by MB
LEFT JOIN STATE_CHANGE_LOG scl_ptype
ON
    cil.CENTER = scl_ptype.CENTER
    AND cil.ID = scl_ptype.ID
    AND scl_ptype.ENTRY_TYPE = 3
    AND longToDate(scl_ptype.ENTRY_START_TIME) <= (:MemberBaseDate +1) -- Date
    AND
        (scl_ptype.ENTRY_END_TIME IS NULL
        OR longToDate(scl_ptype.ENTRY_END_TIME) > (:MemberBaseDate +1))
-----------------------------------------------------------------	
-- personstatus at the time choosen
-- added by MB
LEFT JOIN STATE_CHANGE_LOG scl_pstatus
ON
    cil.CENTER = scl_pstatus.CENTER
    AND cil.ID = scl_pstatus.ID
    AND scl_pstatus.ENTRY_TYPE = 1
    AND longToDate(scl_pstatus.ENTRY_START_TIME) <= (:MemberBaseDate +1) -- Date
    AND
        (scl_pstatus.ENTRY_END_TIME IS NULL
        OR longToDate(scl_pstatus.ENTRY_END_TIME) > (:MemberBaseDate +1))
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
	compRel.CENTER = cil.CENTER
    AND compRel.ID= cil.ID
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
	cil.CHECKIN_CENTER IN (:ChosenScope)
	AND cil.CHECKIN_TIME >= datetolong(TO_CHAR(:MemberBaseDate, 'YYYY-MM-DD HH24:MI'))
	AND cil.CHECKIN_TIME <= datetolong(TO_CHAR(:MemberBaseDate, 'YYYY-MM-DD HH24:MI')) + 86400 * 1000 - 1
--	AND cil.CHECKIN_TIME BETWEEN datetolong(TO_CHAR(TRUNC(exerpsysdate() -1), 'YYYY-MM-DD HH24:MI')) AND (datetolong(TO_CHAR(TRUNC(exerpsysdate() -1), 'YYYY-MM-DD HH24:MI')) + 86399 * 1000)
	
ORDER BY
	cil.CHECKIN_CENTER,
	cil.CHECKIN_TIME