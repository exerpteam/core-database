-- The extract is extracted from Exerp on 2026-02-08
--  
WITH
    PARAMS AS
    (
        SELECT
                /*+ materialize */
				datetolongTZ(TO_CHAR(TRUNC(to_date(getcentertime(c.id), 'YYYY-MM-DD HH24:MI')), 'YYYY-MM-DD HH24:MI'),co.DEFAULTTIMEZONE) AS longDate,
				TRUNC(to_date(getcentertime(c.id), 'YYYY-MM-DD HH24:MI')-1) AS previousDay,
                c.ID AS CenterID
        FROM CENTERS c
        JOIN COUNTRIES co ON c.COUNTRY = co.ID
    )
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
    cen.country AS "COUNTRY",
	cen.EXTERNAL_ID AS "COST",
	COUNT(CASE WHEN scl_ptype.PERSONTYPE = 0 THEN sub.ID END) AS "PRIVATE",
	COUNT(CASE WHEN scl_ptype.PERSONTYPE = 1 THEN sub.ID END) AS "STUDENT",
	COUNT(CASE WHEN scl_ptype.PERSONTYPE = 3 THEN sub.ID END) AS "FRIEND",
	COUNT(CASE WHEN scl_ptype.PERSONTYPE = 4 THEN sub.ID END) AS "CORPORATE",
	COUNT(CASE WHEN scl_ptype.PERSONTYPE = 5 THEN sub.ID END) AS "ONEMANCORPORATE",
	COUNT(CASE WHEN scl_ptype.PERSONTYPE = 6 THEN sub.ID END) AS "FAMILY",
	COUNT(CASE WHEN scl_ptype.PERSONTYPE = 7 THEN sub.ID END) AS "SENIOR",    
COUNT (CASE WHEN add_months(scl_ptype.BIRTHDATE, 20*12) >= (current_timestamp) THEN sub.ID END) AS "Age (0-19)", 	
COUNT(CASE WHEN add_months(scl_ptype.BIRTHDATE, 20 * 12) <= (current_timestamp) and add_months(scl_ptype.BIRTHDATE, 30 * 12) >  (current_timestamp) then 1 end) AS "Age (20-29)",
COUNT(CASE WHEN add_months(scl_ptype.BIRTHDATE, 30 * 12) <= (current_timestamp) and add_months(scl_ptype.BIRTHDATE, 40 * 12) >  (current_timestamp) then 1 end) AS "Age (30-39)",
COUNT(CASE WHEN add_months(scl_ptype.BIRTHDATE, 40 * 12) <= (current_timestamp) and add_months(scl_ptype.BIRTHDATE, 50 * 12) >  (current_timestamp) then 1 end) AS "Age (40-49)",
COUNT(CASE WHEN add_months(scl_ptype.BIRTHDATE, 50 * 12) <= (current_timestamp) and add_months(scl_ptype.BIRTHDATE, 60 * 12) >  (current_timestamp) then 1 end) AS "Age (50-59)",
COUNT(CASE WHEN add_months(scl_ptype.BIRTHDATE, 60 * 12) <= (current_timestamp) and add_months(scl_ptype.BIRTHDATE, 70 * 12) >  (current_timestamp) then 1 end) AS "Age (60-69)",
COUNT (CASE WHEN add_months(scl_ptype.BIRTHDATE, 70*12) <= (current_timestamp) THEN sub.ID END) AS "Age (+70)",
COUNT(*) AS "MEMBERS"
	-------------------------------------------------------------

FROM SUBSCRIPTIONS sub
JOIN PARAMS params ON params.CenterID = sub.CENTER
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
-----------------------------------------------------------------	
-- persontype at the time choosen
-- added by MB
/* not used due to the fact that we join on dates and not timestamp
LEFT JOIN STATE_CHANGE_LOG scl_ptype
ON
    sub.OWNER_CENTER = scl_ptype.CENTER
    AND sub.OWNER_ID = scl_ptype.ID
    AND scl_ptype.ENTRY_TYPE = 3
    AND longToDate(scl_ptype.ENTRY_START_TIME) < TRUNC(current_timestamp) -- Date
    AND
        (scl_ptype.ENTRY_END_TIME IS NULL
        OR longToDate(scl_ptype.ENTRY_END_TIME) > TRUNC(current_timestamp -1))
*/
-----------------------------------------------------------------
LEFT JOIN PERSONS scl_ptype
ON
    sub.OWNER_CENTER = scl_ptype.CENTER
    AND sub.OWNER_ID = scl_ptype.ID
-----------------------------------------------------------------	
WHERE
	sub.OWNER_CENTER IN (:Scope)
	------------------	
	/* only include subscriptions active on date */
	AND sub.START_DATE <= params.previousDay -- Date
	AND
		(sub.END_DATE IS NULL
		OR sub.END_DATE >= params.previousDay) -- Date
	-------------------
	/* don't include subscriptions with enddate same day or before startdate */
	AND 
		(sub.START_DATE < sub.END_DATE
		OR sub.END_DATE IS NULL)
	-------------------
	AND sub.CREATION_TIME < params.longDate -- make sure we dont include sales with start date in past
	/* cannot filter on active on frozen since active on last day means an ended subscription in window when the query is actually running */
	AND sub.STATE IN (2, 4) -- only include subscriptions that are active or frozen
	AND scl_ptype.PERSONTYPE != 2 -- exclude staff	
	AND prod.PRIMARY_PRODUCT_GROUP_ID IN (7, 8, 9, 10, 11, 12, 218, 219, 221, 222, 3631, 2024, 13224, 13424, 12224, 11230, 16024)
	-- Product groups
	-- 7-9 = EFT Subscriptions, 10-12 = CASH subscriptions, 
	-- 218+222 = EFT campaign subscriptions, 219+221 = CASH campaign subscriptions
	-- 18 = add-on subscriptions, 624 = Lifestyle, 826 = Excluded
GROUP BY
	cen.COUNTRY,
	cen.EXTERNAL_ID
ORDER BY
	cen.COUNTRY,
	cen.EXTERNAL_ID
