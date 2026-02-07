WITH PARAMS AS MATERIALIZED
(
  SELECT
      dateToLongTZ(to_char($$For_Date$$,'YYYY-MM-DD HH24:MI'),'Europe/London') AS FROM_DATE,
	  dateToLongTZ(to_char($$For_Date$$,'YYYY-MM-DD HH24:MI'),'Europe/London')+24*60*60*1000 AS TO_DATE
   FROM DUAL
)
-- Return all members with person extended attribute "PUREGYMATHOME" set to true until the specified date 
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
	PARAMS
CROSS JOIN
(
SELECT 
    pcl_2.PERSON_CENTER, pcl_2.PERSON_ID, max(pcl_2.id) as maxid
FROM
	PARAMS
CROSS JOIN
	PERSON_EXT_ATTRS pa
JOIN	   
    PERSON_CHANGE_LOGS pcl_2
ON
    pa.PERSONCENTER = pcl_2.PERSON_CENTER
    AND pa.PERSONID = pcl_2.PERSON_ID
WHERE
   pcl_2.PERSON_CENTER in ($$Scope$$)
   AND pa.NAME = 'PUREGYMATHOME'
   AND pcl_2.CHANGE_ATTRIBUTE = 'PUREGYMATHOME'
   AND pcl_2.ENTRY_TIME < params.To_Date
   AND pcl_2.ENTRY_TIME >= 1583017200000  -- 2020-03-01 
GROUP BY 
   pcl_2.PERSON_CENTER, pcl_2.PERSON_ID
) v1
JOIN
	PERSON_CHANGE_LOGS pcl
ON 
	pcl.ID = v1.maxID 
	AND pcl.NEW_VALUE = 'true'
JOIN
	PERSONS p
ON
	pcl.PERSON_CENTER = p.CENTER
	AND pcl.PERSON_ID = p.ID
JOIN
	PERSONS cp
ON
    cp.center = p.CURRENT_PERSON_CENTER
    AND cp.id = p.CURRENT_PERSON_ID
JOIN
    SUBSCRIPTIONS s
ON
    s.OWNER_CENTER = p.CENTER
    AND s.OWNER_ID = p.ID
JOIN
    STATE_CHANGE_LOG SCL
ON
    scl.CENTER = s.center
	AND scl.ID = s.ID
	AND SCL.ENTRY_TYPE = 2 -- subscriptions
    AND SCL.STATEID in (2) -- only actives 
    AND SCL.BOOK_START_TIME < pcl.ENTRY_TIME+5*60*1000  -- 5 min buffer PROD
	--AND SCL.BOOK_START_TIME < pcl.ENTRY_TIME+30*1000  -- 30 sec buffer TEST
    AND (SCL.BOOK_END_TIME IS NULL  OR  SCL.BOOK_END_TIME+5*60*1000 >= pcl.ENTRY_TIME ) -- 5 min buffer on PROD
	--AND (SCL.BOOK_END_TIME IS NULL  OR  SCL.BOOK_END_TIME+30*1000 >= pcl.ENTRY_TIME ) -- 30 sec buffer on TEST
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
JOIN
	CENTERS c
ON
	c.ID = cp.CENTER
LEFT JOIN
    PRODUCTS fp
ON
    fp.CENTER = st.FREEZEPERIODPRODUCT_CENTER	
    AND fp.ID = st.FREEZEPERIODPRODUCT_ID	
LEFT JOIN 
   ACCOUNT_RECEIVABLES ar
ON
   ar.CUSTOMERCENTER = cp.CENTER
   AND ar.CUSTOMERID = cp.ID 
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
   SCL.STATEID in (2) -- only actives 
   AND SCL.BOOK_START_TIME < pcl.ENTRY_TIME+5*60*1000  -- 5 min buffer on PROD 
   --AND SCL.BOOK_START_TIME < pcl.ENTRY_TIME+30*1000  -- 30 sec buffer on TEST
   AND cp.PERSONTYPE != 2  -- exclude Staff
   AND cp.CENTER in ($$Scope$$)
   AND NOT EXISTS 
   ( -- exclude company 100p64204  (Bluelight Card)
		SELECT 1 FROM RELATIVES R
		WHERE R.RTYPE = 2 AND R.CENTER = 100 AND R.ID = 64204  
				AND R.STATUS = 1 AND R.RELATIVECENTER = cp.CENTER AND R.RELATIVEID = cp.ID
   )
   AND EXISTS 
   (
     -- if member is in ACTIVE and FROZEN state
	 SELECT 1 FROM STATE_CHANGE_LOG ps
	 WHERE ps.ENTRY_TYPE = 1 
	 AND ps.STATEID in (1,3)
     AND ps.CENTER = cp.CENTER 
	 AND ps.ID = cp.ID 
	 AND ps.ENTRY_START_TIME <= PARAMS.FROM_DATE AND (ps.ENTRY_END_TIME IS NULL OR ps.ENTRY_END_TIME >= PARAMS.FROM_DATE )
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
	c.ID = p.CENTER
JOIN
	PRODUCTS pr
ON
	pr.CENTER = st.CENTER
	AND pr.ID = st.ID
JOIN
    STATE_CHANGE_LOG scl
ON
    s.CENTER = scl.CENTER
	AND s.ID = scl.ID
    AND SCL.BOOK_START_TIME < PARAMS.TO_DATE
    AND (SCL.BOOK_END_TIME IS NULL OR  SCL.BOOK_END_TIME >= PARAMS.FROM_DATE )
    AND SCL.ENTRY_TYPE = 2
    AND SCL.STATEID = 2	
	
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
   AND (s.START_DATE < s.END_DATE OR s.END_DATE IS NULL) -- exclude Deleted subscription
   AND EXISTS -- Product Group PGT
   (SELECT 1 FROM PRODUCT_AND_PRODUCT_GROUP_LINK ppl WHERE ppl.PRODUCT_CENTER = pr.CENTER AND  ppl.PRODUCT_ID = pr.ID AND ppl.PRODUCT_GROUP_ID = 11801)
   --If a member has the purchase a product from the 'PGT' product group and stops their subscription on same day then exclude the member.
   AND NOT EXISTS
   (SELECT 1 FROM SUBSCRIPTIONS se WHERE se.OWNER_CENTER = p.CENTER AND se.OWNER_ID = p.ID AND se.END_DATE = ss.SALES_DATE)

