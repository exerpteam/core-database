WITH PARAMS AS 
(
  SELECT 
      dateToLongTZ(to_char(:FROM_DATE,'YYYY-MM-DD HH24:MI'),'Europe/London') AS FROM_DATE_TS,
	  dateToLongTZ(to_char(:TO_DATE+1,'YYYY-MM-DD HH24:MI'),'Europe/London') AS TO_DATE_TS,
      :FROM_DATE  														     AS FROMDATE,
	  :TO_DATE+1															 AS TODATE
	  
  FROM DUAL
)

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
   AND ss.SALES_DATE >= PARAMS.FROMDATE  AND ss.SALES_DATE < PARAMS.TODATE
   AND EXISTS -- Product Group PGT
   (SELECT 1 FROM PRODUCT_AND_PRODUCT_GROUP_LINK ppl WHERE ppl.PRODUCT_CENTER = pr.CENTER AND  ppl.PRODUCT_ID = pr.ID AND ppl.PRODUCT_GROUP_ID = 11801)

UNION ALL

SELECT 
    DISTINCT
    c.SHORTNAME 					AS "Center name",
	cp.center||'p'||cp.id  			AS "Person ID",
	cp.EXTERNAL_ID 					AS "External ID",
	TO_CHAR(longtodateC(pcl.ENTRY_TIME,100),'DD/MM/YYYY') 	AS  "Date created",
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
    PERSON_CHANGE_LOGS pcl
ON
    cp.ID = pcl.PERSON_ID	
    AND cp.CENTER = pcl.PERSON_CENTER
	AND pcl.CHANGE_ATTRIBUTE = 'PUREGYMATHOME'
	AND pcl.ENTRY_TIME >= PARAMS.FROM_DATE_TS
	AND pcl.NEW_VALUE = 'true'
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
   AND s.STATE in (2,4,8)
   AND cp.PERSONTYPE != 2  -- exclude Staff
   AND pcl.ENTRY_TIME >= PARAMS.FROM_DATE_TS
   AND pcl.ENTRY_TIME < PARAMS.TO_DATE_TS
   