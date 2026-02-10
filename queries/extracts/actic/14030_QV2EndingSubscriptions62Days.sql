-- The extract is extracted from Exerp on 2026-02-08
--  
/* 
 * Subscriptions with end_date within 42 days
 */
-- TODO
-- filter on productgroups
WITH
    PARAMS AS
    (
        SELECT
                /*+ materialize */
				TRUNC(to_date(getcentertime(c.id), 'YYYY-MM-DD HH24:MI') + 62) AS cutDate,
				TRUNC(to_date(getcentertime(c.id), 'YYYY-MM-DD HH24:MI')) AS todaysDate,
                c.ID AS CenterID
        FROM CENTERS c
        JOIN COUNTRIES co ON c.COUNTRY = co.ID
    )
SELECT
	cen.COUNTRY,
	cen.EXTERNAL_ID 								AS Cost,
	cen.ID 											AS CenterId,
	sub.OWNER_CENTER || 'p' || sub.OWNER_ID 		AS PersonId,
	CAST(EXTRACT('year' FROM age(per.birthdate)) AS VARCHAR)            AS Age,
    CASE  per.PERSONTYPE  WHEN 0 THEN 'PRIVATE'  WHEN 1 THEN 'STUDENT'  WHEN 2 THEN 'STAFF'  WHEN 3 THEN 'FRIEND'  WHEN 4 THEN 'CORPORATE'  WHEN 5 THEN 'ONEMANCORPORATE'  WHEN 6 THEN 'FAMILY'  WHEN 7 THEN 'SENIOR'  WHEN 8 THEN 'GUEST'  WHEN 9 THEN 'CONTACT'  ELSE 'UNKNOWN' END AS PERSONTYPE,
	company.LASTNAME 								AS Company_Name,
	CA.NAME 										AS AGREEMENT_NAME,
    CASE  sub.STATE  WHEN 2 THEN 'ACTIVE'  WHEN 3 THEN 'ENDED'  WHEN 4 THEN 'FROZEN'  WHEN 7 THEN 'WINDOW'  WHEN 8 THEN 'CREATED' ELSE 'UNKNOWN' END AS subscription_STATE,
    CASE  sub.SUB_STATE  WHEN 1 THEN 'NONE'  WHEN 2 THEN 'AWAITING_ACTIVATION'  WHEN 3 THEN 'UPGRADED'  WHEN 4 THEN 'DOWNGRADED'  WHEN 5 THEN 'EXTENDED'  WHEN 6 THEN  'TRANSFERRED' WHEN 7 THEN 'REGRETTED' WHEN 8 THEN 'CANCELLED' WHEN 9 THEN 'BLOCKED' ELSE 'UNKNOWN' END  AS SUBSCRIPTION_SUB_STATE,
	CASE  st.ST_TYPE  WHEN 0 THEN 'CASH'  WHEN 1 THEN 'EFT' END 			AS PaymentType,
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
JOIN PARAMS params ON params.CenterID = sub.CENTER
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
-----------------------------------------------------------------
/* Current company relation at the time extract is running */
LEFT JOIN RELATIVES companyAgrRel
ON
    sub.OWNER_CENTER = companyAgrRel.CENTER
    AND sub.OWNER_ID = companyAgrRel.ID
    AND companyAgrRel.RTYPE = 3
    AND companyAgrRel.STATUS = 1
LEFT JOIN COMPANYAGREEMENTS ca
ON
    ca.CENTER = companyAgrRel.RELATIVECENTER
    AND ca.ID = companyAgrRel.RELATIVEID
    AND ca.SUBID = companyAgrRel.RELATIVESUBID
LEFT JOIN PERSONS company
ON
    company.CENTER = ca.CENTER
    AND company.ID = ca.id
    AND company.sex = 'C'		
-----------------------------------------------------------------
WHERE 
	sub.CENTER IN (:ChosenScope)
	AND sub.END_DATE >= params.todaysDate
	AND sub.END_DATE < params.cutDate
	AND per.PERSONTYPE != 2
	-------------------
	/* don't include subscriptions with enddate same day or before startdate */
	AND 
		(sub.START_DATE < sub.END_DATE
		OR sub.END_DATE IS NULL)
	-------------------
	-- AND sub.STATE IN(2, 4) -- only include active or frozen
ORDER BY
	sub.END_DATE
