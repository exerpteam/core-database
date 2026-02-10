-- The extract is extracted from Exerp on 2026-02-08
--  
/* active subscriptions reworked */

-- TODO
-- Totals dont match sum of other due to the fact that there is a mismatch in the join of historical persontypes. ie guest!
-- Get historical subscription status in case we want to check historical members count.

SELECT
----------------------------------------------------------------

	cen.NAME AS CenterName,
	cen.ID AS CenterID,
	P.CITY, 
	sub.OWNER_CENTER || 'p' || sub.OWNER_ID 		AS PersonId,
	pem.txtvalue AS email,
	
    DECODE (scl_ptype.PERSONTYPE, 0,'PRIVATE', 1,'STUDENT', 2,'STAFF', 3,'FRIEND', 4,'CORPORATE', 5,'ONEMANCORPORATE', 6,'FAMILY', 7,'SENIOR', 8,'GUEST', 9,'CONTACT', 'UNKNOWN') AS PERSONTYPE,
	sub.CENTER || 'ss' || sub.ID					AS SubscriptionId,
    DECODE (sub.STATE, 2,'ACTIVE', 3,'ENDED', 4,'FROZEN', 7,'WINDOW', 8,'CREATED','UNKNOWN') AS subscription_STATE,
    DECODE (sub.SUB_STATE, 1,'NONE', 2,'AWAITING_ACTIVATION', 3,'UPGRADED', 4,'DOWNGRADED', 5,'EXTENDED', 6, 'TRANSFERRED',7,'REGRETTED',8,'CANCELLED',9,'BLOCKED','UNKNOWN')  AS SUBSCRIPTION_SUB_STATE,
    DECODE(st.ST_TYPE, 0, 'CASH', 1, 'EFT', 'UKNOWN') as PaymentType,
	

	sub.START_DATE 			AS start_DATE,	
	sub.BINDING_END_DATE 	AS binding_END_DATE,
	sub.END_DATE				AS end_DATE,
	sub.BINDING_PRICE,
	prod.NAME AS Product_Name
	-------------------------------------------------------------

FROM SUBSCRIPTIONS sub
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
LEFT JOIN CENTERS cen
ON
	sub.OWNER_CENTER = cen.ID
LEFT JOIN PERSONS p
ON
	sub.OWNER_CENTER = p.CENTER
	AND sub.OWNER_ID = p.ID
	
	
	
LEFT JOIN PERSON_EXT_ATTRS pem
ON
    pem.personcenter = p.center
    AND pem.personid = p.id
    AND pem.name = '_eClub_Email'

-----------------------------------------------------------------	
-- persontype at the time choosen
-- added by MB
/* not used due to the fact that we join on dates and not timestamp
LEFT JOIN STATE_CHANGE_LOG scl_ptype
ON
    sub.OWNER_CENTER = scl_ptype.CENTER
    AND sub.OWNER_ID = scl_ptype.ID
    AND scl_ptype.ENTRY_TYPE = 3
    AND longToDate(scl_ptype.ENTRY_START_TIME) < (MemberBaseDate +1) -- Date
    AND
        (scl_ptype.ENTRY_END_TIME IS NULL
        OR longToDate(scl_ptype.ENTRY_END_TIME) > MemberBaseDate)
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
	AND sub.START_DATE <= TRUNC(exerpsysdate() -1) -- Date
	AND
		(sub.END_DATE IS NULL
		OR sub.END_DATE >= TRUNC(exerpsysdate() -1)) -- Date
	-------------------
	/* don't include subscriptions with enddate same day or before startdate */
	AND 
		(sub.START_DATE < sub.END_DATE
		OR sub.END_DATE IS NULL)
	-------------------
	AND longToDate(sub.CREATION_TIME) < TRUNC(exerpsysdate()) -- make sure we dont include sales with start date in past
	/* cannot filter on active on frozen since active on last day means an ended subscription in window when the query is actually running */
	--AND sub.STATE IN (2, 4) -- only include subscriptions that are active or frozen
	AND scl_ptype.PERSONTYPE != 2 -- exclude staff
	AND prod.PRIMARY_PRODUCT_GROUP_ID IN (7, 8, 9, 10, 11, 12, 218, 219, 221, 222)
	-- Product groups
	-- 7-9 = EFT Subscriptions, 10-12 = CASH subscriptions, 
	-- 218+222 = EFT campaign subscriptions, 219+221 = CASH campaign subscriptions
	-- 18 = add-on subscriptions, 624 = Lifestyle, 826 = Excluded
