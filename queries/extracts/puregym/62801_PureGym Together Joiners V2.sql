-- The extract is extracted from Exerp on 2026-02-08
-- https://clublead.atlassian.net/browse/ST-11130
WITH PARAMS AS 
(
  SELECT 
   /*+ materialize */
      longtodateTZ(:FROM_DATE,'Europe/London') AS FROM_DATE,
	  longtodateTZ(:FROM_DATE,'Europe/London')+1 AS TO_DATE
  FROM DUAL

)

-- Return all members with person extended attribute "PUREGYMATHOME" set to true between the date range
-- This is a time safe report, the active subcription info on that time will be listed
SELECT 
   DISTINCT
    c.SHORTNAME 					AS "Center name",
  	cp.center||'p'||cp.id  			AS "Person ID",
	cp.EXTERNAL_ID 					AS "External ID",
	TO_CHAR(longtodateTZ(pcl.ENTRY_TIME,'Europe/London'),'DD/MM/YYYY') 	AS  "Date created",
	pr.NAME 						AS "Subscription",
	DECODE(s.state,2,'Active',3,'Ended',4,'Frozen',7,'Window',8,'Created','Undefined') AS "Subscription State",
	CASE WHEN s.BINDING_END_DATE >= trunc(sysdate) THEN s.BINDING_PRICE
		 ELSE s.SUBSCRIPTION_PRICE
	END  							AS "Subscription Price",
	CASE WHEN s.STATE = 4 THEN fp.PRICE
						  ELSE null
	END 					        AS "PG T Price",
	pag.INDIVIDUAL_DEDUCTION_DAY    AS "DD Date"
FROM
    PERSONS p
JOIN
    PERSONS cp
ON
    cp.CENTER = p.CURRENT_PERSON_CENTER
    AND cp.id = p.CURRENT_PERSON_ID
JOIN
	CENTERS c
ON
	c.ID = cp.CENTER
JOIN		
    PERSON_CHANGE_LOGS pcl
ON
    p.CENTER = pcl.PERSON_CENTER
	AND p.ID = pcl.PERSON_ID	
	AND pcl.CHANGE_ATTRIBUTE = 'PUREGYMATHOME'
JOIN
	SUBSCRIPTIONS s
ON
    p.center = s.owner_center
	AND p.id = s.owner_id
JOIN
    STATE_CHANGE_LOG SCL
ON
    scl.CENTER = s.center
	AND scl.ID = s.ID
	AND SCL.ENTRY_TYPE = 2 -- subscriptions
    AND SCL.STATEID = 2 -- only actives 
    AND SCL.BOOK_START_TIME < pcl.ENTRY_TIME+60*60*60000  -- 1 hour buffer, some record
    AND (SCL.BOOK_END_TIME IS NULL  OR  SCL.BOOK_END_TIME+60*60*1000 >= pcl.ENTRY_TIME ) -- 1 min buffer
JOIN
    SUBSCRIPTIONTYPES st
ON
    s.SUBSCRIPTIONTYPE_CENTER = st.CENTER
    AND s.SUBSCRIPTIONTYPE_ID = st.ID
JOIN
	PRODUCTS pr
ON
	pr.CENTER = st.CENTER
	AND pr.ID = st.ID
LEFT JOIN
    PRODUCTS fp
ON
    fp.CENTER = st.FREEZEPERIODPRODUCT_CENTER	
    AND fp.ID = st.FREEZEPERIODPRODUCT_ID	
LEFT JOIN 
   ACCOUNT_RECEIVABLES ar
ON
   ar.CUSTOMERCENTER = p.CENTER
   AND ar.CUSTOMERID = p.ID 
   AND ar.AR_TYPE = 4 -- payment account
LEFT JOIN
   PAYMENT_ACCOUNTS pac
ON 
   pac.center = ar.center 
   AND pac.ID = ar.ID 
LEFT JOIN
   PAYMENT_AGREEMENTS pag
ON 
   pac.ACTIVE_AGR_CENTER = pag.center 
   AND pac.ACTIVE_AGR_ID = pag.ID 
   AND pac.ACTIVE_AGR_SUBID = pag.SUBID 
WHERE
   cp.CENTER in (:Scope)
   AND cp.PERSONTYPE != 2  -- exclude Staff
   AND pcl.CHANGE_ATTRIBUTE = 'PUREGYMATHOME'
   AND pcl.NEW_VALUE = 'true'
   AND pcl.ENTRY_TIME >= :FROM_DATE
   AND pcl.ENTRY_TIME < :FROM_DATE + 24*3600*1000
   AND pcl.ENTRY_TIME >= 1583017200000  -- This line is added to improve the performance 2020-03-01
   -- exclude Temp Access memberships
   AND NOT EXISTS (SELECT 1 FROM PRODUCT_AND_PRODUCT_GROUP_LINK PPL 
					WHERE PPL.PRODUCT_CENTER = PR.CENTER 
					AND PPL.PRODUCT_ID = PR.ID AND PPL.PRODUCT_GROUP_ID =6410)

   -- If a member has the attribute is set to true and false in the same day then exclude the member.
   AND  NOT EXISTS
   (SELECT 1 FROM PERSON_CHANGE_LOGS pcl2 
		WHERE  
			pcl2.PERSON_CENTER = pcl.PERSON_CENTER 
			AND pcl2.PERSON_ID = pcl.PERSON_ID 
			AND pcl2.CHANGE_ATTRIBUTE = 'PUREGYMATHOME'
			AND pcl2.ENTRY_TIME > pcl.ENTRY_TIME
			AND pcl2.ENTRY_TIME < :FROM_DATE + 24*3600*1000
			AND pcl2.NEW_VALUE = 'false'
	)
   AND NOT EXISTS 
   ( -- exclude company 100p64204  (Bluelight Card)
		SELECT 1 FROM RELATIVES R
		WHERE R.RTYPE = 2 AND R.CENTER = 100 AND R.ID = 64204  
				AND R.STATUS = 1 AND R.RELATIVECENTER = cp.CENTER AND R.RELATIVEID = cp.ID
   )

UNION ALL 

-- If a new subscription is sold to new customers within the Product Group called PGT (ID 11801)
SELECT 
    c.SHORTNAME 					AS "Center name",
	cp.center||'p'||cp.id  			AS "Person ID",
	cp.EXTERNAL_ID 					AS "External ID",
	TO_CHAR(ss.SALES_DATE,'DD/MM/YYYY') 	AS  "Date created",
	pr.NAME 						AS "Subscription",
	DECODE(s.state,2,'Active',3,'Ended',4,'Frozen',7,'Window',8,'Created','Undefined') AS "Subscription State",
	CASE WHEN s.BINDING_END_DATE >= trunc(sysdate) THEN s.BINDING_PRICE
		 ELSE s.SUBSCRIPTION_PRICE
	END  							AS "Subscription Price",
	CASE WHEN s.STATE = 4 THEN fp.PRICE
						  ELSE null
	END 					        AS "PG T Price",
	pag.INDIVIDUAL_DEDUCTION_DAY    AS "DD Date"
FROM
	PARAMS
CROSS JOIN
	SUBSCRIPTIONS s
JOIN
    SUBSCRIPTIONTYPES st
ON
    s.SUBSCRIPTIONTYPE_CENTER = st.CENTER
    AND s.SUBSCRIPTIONTYPE_ID = st.ID
JOIN
    SUBSCRIPTION_SALES ss
ON 
	s.CENTER = ss.SUBSCRIPTION_CENTER
	AND s.ID = ss.SUBSCRIPTION_ID
JOIN
	PERSONS p
ON
	s.OWNER_CENTER = p.CENTER
	AND s.OWNER_ID = p.ID
JOIN
	PERSONS cp
ON
    cp.center = p.CURRENT_PERSON_CENTER
    AND cp.id = p.CURRENT_PERSON_ID
JOIN
	CENTERS c
ON
	c.ID = cp.CENTER
JOIN
	PRODUCTS pr
ON
	pr.CENTER = st.CENTER
	AND pr.ID = st.ID
LEFT JOIN
    PRODUCTS fp
ON
    fp.CENTER = st.FREEZEPERIODPRODUCT_CENTER	
    AND fp.ID = st.FREEZEPERIODPRODUCT_ID	
LEFT JOIN 
   ACCOUNT_RECEIVABLES ar
ON
   ar.CUSTOMERCENTER = p.CENTER
   AND ar.CUSTOMERID = p.ID 
   AND ar.AR_TYPE = 4 -- Payment Account
LEFT JOIN
   PAYMENT_ACCOUNTS pac
ON 
   pac.center = ar.center 
   AND pac.ID = ar.ID 
LEFT JOIN
   PAYMENT_AGREEMENTS pag
ON 
   pac.ACTIVE_AGR_CENTER = pag.center 
   AND pac.ACTIVE_AGR_ID = pag.ID 
   AND pac.ACTIVE_AGR_SUBID = pag.SUBID 
WHERE
   cp.CENTER in (:Scope)
   AND cp.PERSONTYPE != 2  -- exclude Staff
   AND ss.SALES_DATE >= PARAMS.FROM_DATE  AND ss.SALES_DATE < PARAMS.TO_DATE
   AND (s.START_DATE < s.END_DATE OR s.END_DATE IS NULL) -- exclude Deleted subscription
   AND EXISTS -- if there is a sale within the Product Group PGT
   (SELECT 1 FROM PRODUCT_AND_PRODUCT_GROUP_LINK ppl WHERE ppl.PRODUCT_CENTER = pr.CENTER AND  ppl.PRODUCT_ID = pr.ID AND ppl.PRODUCT_GROUP_ID = 11801)
   --If a member has the purchase a product from the 'PGT' product group and stops their subscription on same day then exclude the member.
   AND NOT EXISTS
   (SELECT 1 FROM SUBSCRIPTIONS se WHERE se.OWNER_CENTER = p.CENTER AND se.OWNER_ID = p.ID AND se.END_DATE = ss.SALES_DATE)
   
   
   