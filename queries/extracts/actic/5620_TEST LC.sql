/* active subscriptions reworked */

-- TODO
-- Totals dont match sum of other due to the fact that there is a mismatch in the join of historical persontypes. ie guest!
-- Get historical subscription status in case we want to check historical members count.

SELECT DISTINCT
----------------------------------------------------------------
    cen.COUNTRY,
	cen.EXTERNAL_ID 								AS Cost,
	cen.name,
	cen.ID 											AS CenterId,
	sub.OWNER_CENTER || 'p' || sub.OWNER_ID 		AS PersonId,
	TO_CHAR(trunc(months_between(TRUNC(exerpsysdate()),p.birthdate)/12)) AS Age,
	p.sex,
		FIRST_ACTIVE_START_DATE, P.LAST_ACTIVE_START_DATE AS 
        LAST_ACTIVE_START_DATE, P.LAST_ACTIVE_END_DATE AS 
        LAST_ACTIVE_END_DATE, P.MEMBERDAYS AS MEMBERDAYS, 
        P.ACCUMULATED_MEMBERDAYS AS ACCUMULATED_MEMBERDAYS, CASE WHEN 
        P.LAST_ACTIVE_START_DATE IS NULL THEN 0 WHEN 
        P.LAST_ACTIVE_END_DATE IS NULL THEN TRUNC(TO_DATE('2019-02-12', 
        'YYYY-MM-DD') - P.LAST_ACTIVE_START_DATE) + 1 ELSE P.MEMBERDAYS 
        END AS UNBROKEN_MEMBER_DAYS, CASE WHEN P.LAST_ACTIVE_END_DATE 
        IS NULL THEN TRUNC(TO_DATE('2019-02-12', 'YYYY-MM-DD') - 
        P.LAST_ACTIVE_START_DATE) + 1 + P.ACCUMULATED_MEMBERDAYS ELSE 
        P.MEMBERDAYS + P.MEMBERDAYS END AS BROKEN_MEMBER_DAYS, 

    DECODE (p.PERSONTYPE, 0,'PRIVATE', 1,'STUDENT', 2,'STAFF', 3,'FRIEND', 4,'CORPORATE', 5,'ONEMANCORPORATE', 6,'FAMILY', 7,'SENIOR', 8,'GUEST', 9,'CONTACT', 'UNKNOWN') AS PERSONTYPE,
	--sub.CENTER || 'ss' || sub.ID					AS SubscriptionId,
    --DECODE (sub.STATE, 2,'ACTIVE', 3,'ENDED', 4,'FROZEN', 7,'WINDOW', 8,'CREATED','UNKNOWN') AS subscription_STATE,
    --DECODE (sub.SUB_STATE, 1,'NONE', 2,'AWAITING_ACTIVATION', 3,'UPGRADED', 4,'DOWNGRADED', 5,'EXTENDED', 6, 'TRANSFERRED',7,'REGRETTED',8,'CANCELLED',9,'BLOCKED','UNKNOWN')  AS SUBSCRIPTION_SUB_STATE,
    --DECODE(st.ST_TYPE, 0, 'CASH', 1, 'EFT', 'UKNOWN') as PaymentType,
	

	--longToDate(sub.CREATION_TIME) AS Sales_Date,
	--sub.START_DATE 			AS start_DATE,	
	--sub.BINDING_END_DATE 	AS binding_END_DATE,
	--sub.END_DATE				AS end_DATE,
	--sub.BINDING_PRICE,
-------------------------------------------
--CASE
--WHEN ss.SUBSCRIPTION_TYPE_TYPE = 0 THEN ceil(( ss.PRICE_PERIOD /( ( --ss.END_DATE - ss.START_DATE)-2) )*30) -- cash pr month
--WHEN ss.SUBSCRIPTION_TYPE_TYPE = 1 THEN ss.PRICE_PERIOD
--END   AS MonthlyPrice,
	--prod.NAME AS CurrentSubscription,

(NVL(per_par.par_count,0) + NVL(per_booked_par.par_count,0)) AS TotalBookedClasses,

(NVL(per_par2.par_count2,0) + NVL(per_booked_par2.par_count2,0)) AS TotalBookedinstructions,



 NVL(per_att.att_count, 0)                                    AS TotalCheckIns
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


LEFT JOIN
    (
        SELECT
            attends.person_center,
            attends.person_id,
            COUNT(*)                AS att_count,
            MAX(attends.start_time) AS max_start_time
            --, sum(case when attends.start_time > (datetolong(to_char(exerpsysdate(), 'YYYY-MM-DD HH24:MI')) - 30 * 86400 * 1000) then 1 else 0 end) as count_30_days
        FROM
            attends
        WHERE
            attends.state = 'ACTIVE'
        GROUP BY
            attends.person_center,
            attends.person_id
    )
    per_att
ON
    per_att.person_center = sub.OWNER_CENTER
AND per_att.person_id = sub.OWNER_ID

LEFT JOIN
    (
        SELECT
            COUNT(*) par_count,
            par.PARTICIPANT_CENTER,
            par.PARTICIPANT_ID,
            MAX(par.START_TIME) LAST_START_TIME
        FROM
            PARTICIPATIONS par
        JOIN BOOKINGS bk
        ON
            bk.center = par.BOOKING_CENTER
        AND bk.id = par.BOOKING_ID
        JOIN ACTIVITY act
        ON
            bk.ACTIVITY = act.ID
        WHERE
            par.STATE IN ('PARTICIPATION')
        AND act.ACTIVITY_TYPE = 2
        GROUP BY
            par.PARTICIPANT_CENTER,
            par.PARTICIPANT_ID
    )
    per_par
ON
    per_par.PARTICIPANT_CENTER = sub.OWNER_CENTER
AND per_par.PARTICIPANT_ID = sub.OWNER_ID
LEFT JOIN
    (
        SELECT
            COUNT(*) par_count,
            par.PARTICIPANT_CENTER,
            par.PARTICIPANT_ID,
            MIN(par.START_TIME) FIRST_START_TIME,
            MAX(par.START_TIME) LAST_START_TIME
        FROM
            PARTICIPATIONS par
        JOIN BOOKINGS bk
        ON
            bk.center = par.BOOKING_CENTER
        AND bk.id = par.BOOKING_ID
        JOIN ACTIVITY act
        ON
            bk.ACTIVITY = act.ID
        WHERE
            par.STATE IN ('BOOKED')
        AND act.ACTIVITY_TYPE = 2
        GROUP BY
            par.PARTICIPANT_CENTER,
            par.PARTICIPANT_ID
    )
    per_booked_par
ON
    per_booked_par.PARTICIPANT_CENTER = sub.OWNER_CENTER
AND per_booked_par.PARTICIPANT_ID = sub.OWNER_ID







LEFT JOIN
    (
        SELECT
            COUNT(*) par_count2,
            par2.PARTICIPANT_CENTER,
            par2.PARTICIPANT_ID,
            MAX(par2.START_TIME) LAST_START_TIME
        FROM
            PARTICIPATIONS par2
        JOIN BOOKINGS bk2
        ON
            bk2.center = par2.BOOKING_CENTER
        AND bk2.id = par2.BOOKING_ID
        JOIN ACTIVITY act2
        ON
            bk2.ACTIVITY = act2.ID
        WHERE
            par2.STATE IN ('PARTICIPATION')
        AND act2.ACTIVITY_TYPE IN (3,4,5,6)
        GROUP BY
            par2.PARTICIPANT_CENTER,
            par2.PARTICIPANT_ID
    )
    per_par2
ON
    per_par2.PARTICIPANT_CENTER = sub.OWNER_CENTER
AND per_par2.PARTICIPANT_ID = sub.OWNER_ID


LEFT JOIN
    (
        SELECT
            COUNT(*) par_count2,
            par2.PARTICIPANT_CENTER,
            par2.PARTICIPANT_ID,
            MIN(par2.START_TIME) FIRST_START_TIME,
            MAX(par2.START_TIME) LAST_START_TIME
        FROM
            PARTICIPATIONS par2
        JOIN BOOKINGS bk2
        ON
            bk2.center = par2.BOOKING_CENTER
        AND bk2.id = par2.BOOKING_ID
        JOIN ACTIVITY act2
        ON
            bk2.ACTIVITY = act2.ID
        WHERE
            par2.STATE IN ('BOOKED')
        AND act2.ACTIVITY_TYPE IN (3,4,5,6)
        GROUP BY
            par2.PARTICIPANT_CENTER,
            par2.PARTICIPANT_ID
    )
    per_booked_par2
ON
    per_booked_par2.PARTICIPANT_CENTER = sub.OWNER_CENTER
AND per_booked_par2.PARTICIPANT_ID = sub.OWNER_ID






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
	AND sub.STATE IN (2, 4) -- only include subscriptions that are active or frozen
	AND p.PERSONTYPE != 2 -- exclude staff
	AND prod.PRIMARY_PRODUCT_GROUP_ID IN (7, 8, 9, 10, 11, 12, 218, 219, 221, 222)
	-- Product groups
	-- 7-9 = EFT Subscriptions, 10-12 = CASH subscriptions, 
	-- 218+222 = EFT campaign subscriptions, 219+221 = CASH campaign subscriptions
	-- 18 = add-on subscriptions, 624 = Lifestyle, 826 = Excluded
ORDER BY
	cen.COUNTRY,
	cen.EXTERNAL_ID	