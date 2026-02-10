-- The extract is extracted from Exerp on 2026-02-08
-- Extension of Active memberships
/* active subscriptions reworked */
/**
* Creator: Martin Blomgren
* Purpose: Rework of Active Subscriptions. Should show further grouped information of memberships.
* Note: Functionality seems to be incorrect according to authors comment.
*/

-- TODO
-- Totals dont match sum of other due to the fact that there is a mismatch in the join of historical persontypes. ie guest!
-- Get historical subscription status in case we want to check historical members count.

SELECT

----------------------------------------------------------------
    --cen.COUNTRY,
	cen.EXTERNAL_ID 								AS Cost,
	cen.ID 											AS CenterId,
	cen.name,
	sub.OWNER_CENTER || 'p' || sub.OWNER_ID 		AS PersonId,
	p.fullname,
	p.birthdate,
	p.sex,

    DECODE (scl_ptype.PERSONTYPE, 0,'PRIVATE', 1,'STUDENT', 2,'STAFF', 3,'FRIEND', 4,'CORPORATE', 5,'ONEMANCORPORATE', 6,'FAMILY', 7,'SENIOR', 8,'GUEST', 9,'CONTACT', 'UNKNOWN') AS PERSONTYPE,
	sub.CENTER || 'ss' || sub.ID					AS SubscriptionId,
    DECODE (sub.STATE, 2,'ACTIVE', 3,'ENDED', 4,'FROZEN', 7,'WINDOW', 8,'CREATED','UNKNOWN') AS subscription_STATE,
    DECODE (sub.SUB_STATE, 1,'NONE', 2,'AWAITING_ACTIVATION', 3,'UPGRADED', 4,'DOWNGRADED', 5,'EXTENDED', 6, 'TRANSFERRED',7,'REGRETTED',8,'CANCELLED',9,'BLOCKED','UNKNOWN')  AS SUBSCRIPTION_SUB_STATE,
    DECODE(st.ST_TYPE, 0, 'CASH', 1, 'EFT', 'UKNOWN') as PaymentType,
--	TO_CHAR(longToDate(sub.CREATION_TIME), 'YYYY-MM-DD') AS Sales_Date,
--	TO_CHAR(sub.START_DATE, 'YYYY-MM-DD') 			AS start_DATE,	
--	TO_CHAR(sub.BINDING_END_DATE, 'YYYY-MM-DD') 	AS binding_END_DATE,
--	TO_CHAR(sub.END_DATE, 'YYYY-MM-DD')				AS end_DATE,
	longToDate(sub.CREATION_TIME) AS Sales_Date,
	sub.START_DATE 			AS start_DATE,	
	sub.BINDING_END_DATE 	AS binding_END_DATE,
	sub.END_DATE				AS end_DATE,
  	sub.SUBSCRIPTION_PRICE currentMemberPrice,
	prod.PRICE currentProdPrice,
	CASE
		WHEN sp.TYPE IS NULL THEN 'NORMAL'
		ELSE sp.TYPE
	END	AS Sp_TYPE,
  
-------------------------------------------
--	CASE
--		WHEN ss.SUBSCRIPTION_TYPE_TYPE = 0 THEN ceil(( ss.PRICE_PERIOD /( ( ss.END_DATE - ss.START_DATE)-2) )*30) -- cash pr month
--		WHEN ss.SUBSCRIPTION_TYPE_TYPE = 1 THEN ss.PRICE_PERIOD
--	END   AS MonthlyPrice,
	prod.NAME AS Product_Name,
	prod.GLOBALID AS Global_Id
	-------------------------------------------------------------

FROM SUBSCRIPTIONS sub
INNER JOIN SUBSCRIPTIONTYPES st
ON
	sub.SUBSCRIPTIONTYPE_CENTER = st.CENTER
	AND sub.SUBSCRIPTIONTYPE_ID = st.ID

LEFT JOIN SUBSCRIPTION_PRICE sp
ON
	sub.CENTER = sp.SUBSCRIPTION_CENTER
	AND sub.ID = sp.SUBSCRIPTION_ID
		AND sp.FROM_DATE <= sub.START_DATE
    AND
        sp.TO_DATE IS NULL
	AND SP.CANCELLED = 0


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

	AND sub.START_DATE <= date '2019-01-01' -- Date
	AND
		(sub.END_DATE IS NULL
		OR sub.END_DATE >= date '2019-01-31') -- Date
	-------------------

	
	AND scl_ptype.PERSONTYPE != 2 -- exclude staff

ORDER BY
	cen.COUNTRY,
	cen.EXTERNAL_ID	