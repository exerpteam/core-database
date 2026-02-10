-- The extract is extracted from Exerp on 2026-02-08
-- https://clublead.atlassian.net/browse/ST-11258
WITH PARAMS AS
(
  SELECT
  /*+ materialize */
      dateToLongTZ(to_char($$For_Date$$,'YYYY-MM-DD HH24:MI'),'Europe/London') AS FROM_DATE,
	  dateToLongTZ(to_char($$For_Date$$,'YYYY-MM-DD HH24:MI'),'Europe/London')+24*60*60*1000 AS TO_DATE
	  
   FROM DUAL
)
--include members who have ended a product from Product Group called PGT (ID 11801)
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
	pag.INDIVIDUAL_DEDUCTION_DAY    AS "DD Date",
	'Ended a product from PGT'      AS Reason
FROM
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
   AND s.END_DATE = $$For_Date$$
   AND s.START_DATE < s.END_DATE -- exclude Deleted subscription
   AND cp.PERSONTYPE != 2  -- exclude Staff
   AND EXISTS -- Product Group PGT
  (SELECT 1 FROM PRODUCT_AND_PRODUCT_GROUP_LINK ppl WHERE ppl.PRODUCT_CENTER = pr.CENTER AND  ppl.PRODUCT_ID = pr.ID AND ppl.PRODUCT_GROUP_ID = 11801)

UNION ALL

-- returns members who have a 'cancel freeze receipt' journal document with a creation date within the parameters, 
-- if the 'freeze comment' of the freeze in question is 'PureGym Together'.
SELECT 
    c.SHORTNAME 					AS "Center name",
	cp.center||'p'||cp.id  			AS "Person ID",
	cp.EXTERNAL_ID 					AS "External ID",
	TO_CHAR(longtodateC(je.CREATION_TIME,100),'DD/MM/YYYY') 	AS  "Date created",
	pr.NAME 						AS "Subscription",
	DECODE(s.state,2,'Active',3,'Ended',4,'Frozen',7,'Window',8,'Created','Undefined') AS "Subscription State",
	CASE WHEN s.BINDING_END_DATE >= trunc(sysdate) THEN s.BINDING_PRICE
		 ELSE s.SUBSCRIPTION_PRICE
	END  							AS "Subscription Price",
	CASE WHEN s.STATE = 4 THEN fp.PRICE
						  ELSE null
	END 					        AS "PG T Price",
	pag.INDIVIDUAL_DEDUCTION_DAY    AS "DD Date",
	'Cancel freeze receipt'         AS Reason
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
	PERSON_EXT_ATTRS pa
ON
	p.CENTER = pa.PERSONCENTER
	AND p.ID = pa.PERSONID
	AND pa.NAME = 'PUREGYMATHOME'
JOIN 
    JOURNALENTRIES je
ON
    cp.center = je.PERSON_CENTER
	AND cp.ID = je.PERSON_ID
	AND je.NAME = 'Cancel freeze receipt' 
	AND je.JETYPE = 13
JOIN
	SUBSCRIPTION_FREEZE_PERIOD fp
ON
	s.CENTER = fp.SUBSCRIPTION_CENTER
	AND s.ID = fp.SUBSCRIPTION_ID
	AND fp.STATE = 'ACTIVE'
	AND fp.text = 'PureGym Together'
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
   AND je.CREATION_TIME >= PARAMS.FROM_DATE
   AND je.CREATION_TIME < PARAMS.TO_DATE 

UNION ALL

-- Also include members whose subscription ends on the day set in the parameters, if the person extended attribute is set as ‘TRUE’.
SELECT 
    c.SHORTNAME 					AS "Center name",
	cp.center||'p'||cp.id  			AS "Person ID",
	cp.EXTERNAL_ID 					AS "External ID",
	TO_CHAR(longtodateC(pa.LAST_EDIT_TIME,100),'DD/MM/YYYY') 	AS  "Date created",
	pr.NAME 						AS "Subscription",
	DECODE(s.state,2,'Active',3,'Ended',4,'Frozen',7,'Window',8,'Created','Undefined') AS "Subscription State",
	CASE WHEN s.BINDING_END_DATE >= trunc(sysdate) THEN s.BINDING_PRICE
		 ELSE s.SUBSCRIPTION_PRICE
	END  							AS "Subscription Price",
	CASE WHEN s.STATE = 4 THEN fp.PRICE
						  ELSE null
	END 					        AS "PG T Price",
	pag.INDIVIDUAL_DEDUCTION_DAY    AS "DD Date",
	'Ended subscription'             AS Reason
FROM
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
	PERSON_EXT_ATTRS pa
ON
	p.CENTER = pa.PERSONCENTER
	AND p.ID = pa.PERSONID
	AND pa.NAME = 'PUREGYMATHOME'
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
   AND s.END_DATE = $$For_Date$$
   AND s.SUB_STATE NOT IN (3,4) -- exclude upgrade and downgrade
   AND s.START_DATE < s.END_DATE -- exclude Deleted subscription
   AND cp.PERSONTYPE != 2  -- exclude Staff
   AND pa.TXTVALUE = 'true'
    
UNION ALL      
	

-- Include members who have a ‘change freeze receipt’ journal document entry with a creation date within the parameters. 
-- This entry must only be counted if the new freeze end date is BEFORE the journal note.
SELECT 
    c.SHORTNAME 					AS "Center name",
	cp.center||'p'||cp.id  			AS "Person ID",
	cp.EXTERNAL_ID 					AS "External ID",
	TO_CHAR(longtodateC(je.CREATION_TIME,100),'DD/MM/YYYY') 	AS  "Date created",
	pr.NAME 						AS "Subscription",
	DECODE(s.state,2,'Active',3,'Ended',4,'Frozen',7,'Window',8,'Created','Undefined') AS "Subscription State",
	CASE WHEN s.BINDING_END_DATE >= trunc(sysdate) THEN s.BINDING_PRICE
		 ELSE s.SUBSCRIPTION_PRICE
	END  							AS "Subscription Price",
	CASE WHEN s.STATE = 4 THEN fp.PRICE
						  ELSE null
	END 					        AS "PG T Price",
	pag.INDIVIDUAL_DEDUCTION_DAY    AS "DD Date",
    'Change freeze receipt'         AS Reason
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
	PERSON_EXT_ATTRS pa
ON
	p.CENTER = pa.PERSONCENTER
	AND p.ID = pa.PERSONID
	AND pa.NAME = 'PUREGYMATHOME'
JOIN 
    JOURNALENTRIES je
ON
    cp.center = je.PERSON_CENTER
	AND cp.ID = je.PERSON_ID
	AND je.NAME = 'Change freeze receipt' 
	AND je.JETYPE = 15
JOIN
	SUBSCRIPTION_FREEZE_PERIOD fp
ON
	s.CENTER = fp.SUBSCRIPTION_CENTER
	AND s.ID = fp.SUBSCRIPTION_ID
	AND fp.STATE = 'ACTIVE'
	AND fp.text = 'PureGym Together'
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
   AND je.CREATION_TIME >= PARAMS.FROM_DATE
   AND je.CREATION_TIME < PARAMS.TO_DATE 
   AND fp.ENTRY_TIME <= je.CREATION_TIME
   AND to_date(substr(je.text,-10),'DD/MM/YYYY') < longtodateTZ(je.CREATION_TIME,'Europe/London')

