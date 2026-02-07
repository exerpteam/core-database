
/* active subscriptions reworked */

/* 
 * TOTAL CORPORATE MEMBERS BY DATE
 * Probably going to be used for total corporate members.
 *
 */
-- TODO
-- 

SELECT
----------------------------------------------------------------
    cen.COUNTRY AS "COUNTRY",
	cen.EXTERNAL_ID AS Cost,
	COUNT(CASE WHEN p.PERSONTYPE = 0 THEN sub.ID END) AS Private,
	COUNT(CASE WHEN p.PERSONTYPE = 1 THEN sub.ID END) AS Student,
	COUNT(CASE WHEN p.PERSONTYPE = 3 THEN sub.ID END) AS Friend,
	COUNT(CASE WHEN p.PERSONTYPE = 4 THEN sub.ID END) AS Corporate,
	COUNT(CASE WHEN p.PERSONTYPE = 5 THEN sub.ID END) AS Onemancorporate,
	COUNT(CASE WHEN p.PERSONTYPE = 6 THEN sub.ID END) AS Family,
	COUNT(CASE WHEN p.PERSONTYPE = 7 THEN sub.ID END) AS Senior,    
COUNT (CASE WHEN add_months(p.BIRTHDATE, 20*12) >= (current_timestamp) THEN sub.ID END) AS "Age (0-19)", 	
COUNT(CASE WHEN add_months(p.BIRTHDATE, 20 * 12) <= (current_timestamp) and add_months(p.BIRTHDATE, 30 * 12) >  (current_timestamp) then 1 end) AS "Age (20-29)",
COUNT(CASE WHEN add_months(p.BIRTHDATE, 30 * 12) <= (current_timestamp) and add_months(p.BIRTHDATE, 40 * 12) >  (current_timestamp) then 1 end) AS "Age (30-39)",
COUNT(CASE WHEN add_months(p.BIRTHDATE, 40 * 12) <= (current_timestamp) and add_months(p.BIRTHDATE, 50 * 12) >  (current_timestamp) then 1 end) AS "Age (40-49)",
COUNT(CASE WHEN add_months(p.BIRTHDATE, 50 * 12) <= (current_timestamp) and add_months(p.BIRTHDATE, 60 * 12) >  (current_timestamp) then 1 end) AS "Age (50-59)",
COUNT(CASE WHEN add_months(p.BIRTHDATE, 60 * 12) <= (current_timestamp) and add_months(p.BIRTHDATE, 70 * 12) >  (current_timestamp) then 1 end) AS "Age (60-69)",
COUNT (CASE WHEN add_months(p.BIRTHDATE, 70*12) <= (current_timestamp) THEN sub.ID END) AS "Age (+70)",


 
COUNT(*) AS Members
	-------------------------------------------------------------

FROM SUBSCRIPTIONS sub
INNER JOIN SUBSCRIPTIONTYPES st
ON
	sub.SUBSCRIPTIONTYPE_CENTER = st.CENTER
	AND sub.SUBSCRIPTIONTYPE_ID = st.ID

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
/*
LEFT JOIN PERSONS scl_ptype
ON
    sub.OWNER_CENTER = scl_ptype.CENTER
    AND sub.OWNER_ID = scl_ptype.ID
*/
-----------------------------------------------------------------	
WHERE
	sub.OWNER_CENTER IN (:ChosenScope)
	------------------	
	/* only include subscriptions active on date */
	AND sub.START_DATE <= cast(:MemberBaseDate as date) -- Date
	AND
		(sub.END_DATE IS NULL
		OR sub.END_DATE >= cast(:MemberBaseDate as date)) -- Date
	-------------------
	/* don't include subscriptions with enddate same day or before startdate */
	AND 
		(sub.START_DATE < sub.END_DATE
		OR sub.END_DATE IS NULL)
	-------------------
	AND longToDate(sub.CREATION_TIME) < (cast(:MemberBaseDate as date) + 1) -- make sure we dont include sales with start date in past
	/* cannot filter on active on frozen since active on last day means an ended subscription in window when the query is actually running */
	-- AND sub.STATE IN (2, 4) -- only include subscriptions that are active or frozen
	AND p.PERSONTYPE != 2 -- exclude staff
	
	--AND prod.PRIMARY_PRODUCT_GROUP_ID IN (7, 8, 9, 10, 11, 12, 218, 219, 221, 220, 16024)	
	AND prod.PRIMARY_PRODUCT_GROUP_ID IN (7, 8, 9, 10, 11, 12, 218, 219, 221, 222, 3631, 2024, 13224, 13424, 12224, 11230, 16024)
	-- Product groups
	-- 7-9 = EFT Subscriptions, 10-12 = CASH subscriptions, 
	-- 218+222 = EFT campaign subscriptions, 219+221 = CASH campaign subscriptions
	-- 18 = add-on subscriptions, 624 = Lifestyle, 826 = Excluded
GROUP BY
	cen.COUNTRY,
	cen.EXTERNAL_ID
