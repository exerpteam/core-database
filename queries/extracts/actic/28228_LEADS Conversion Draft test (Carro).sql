SELECT
	per.CENTER || 'p' || per.ID 						AS PersonId,
    DECODE (per.PERSONTYPE, 0,'PRIVATE', 1,'STUDENT', 2,'STAFF', 3,'FRIEND', 4,'CORPORATE', 5,'ONEMANCORPORATE', 6,'FAMILY', 7,'SENIOR', 8,'GUEST','UNKNOWN') AS PersonType,
DECODE (per.STATUS, 0,'LEAD', 1,'ACTIVE', 2,'INACTIVE', 3,'TEMPORARY INACTIVE', 4,'TRANSFERED', 5,'DUPLICATE', 6, 'PROSPECT',7,'DELETED',9,'CONTACT','UNKNOWN')  AS PERSONSTATUS,
	cen.name,
	pea_creationdate.TXTVALUE						 	AS CreationDate,
	j.CREATORCENTER || 'emp' || j.creatorID as creator_Employee,
	emp_person2.FIRSTNAME || ' ' || emp_person2.LASTNAME	AS creator_Name,
	ss.EMPLOYEE_CENTER || 'emp' || ss.EMPLOYEE_ID 	AS Sales_Employee,
	emp_person.FIRSTNAME || ' ' || emp_person.LASTNAME AS Sales_EmployeeName,
	longToDate(sub.CREATION_TIME) 					AS Sales_Date,
	TO_CHAR(sub.START_DATE, 'YYYY-MM-DD') 			AS start_DATE,
	sub.BINDING_END_DATE 							AS binding_END_DATE,
	sub.END_DATE									AS end_DATE,	
	prod.NAME 										AS Product_Name,
    DECODE (sub.STATE, 2,'ACTIVE', 3,'ENDED', 4,'FROZEN', 7,'WINDOW', 8,'CREATED','UNKNOWN') AS subscription_STATE,
    DECODE (sub.SUB_STATE, 1,'NONE', 2,'AWAITING_ACTIVATION', 3,'UPGRADED', 4,'DOWNGRADED', 5,'EXTENDED', 6, 'TRANSFERRED',7,'REGRETTED',8,'CANCELLED',9,'BLOCKED','UNKNOWN')  AS SUBSCRIPTION_SUB_STATE,
	cc2.CODE                              		AS Campiagn_Code_Used,
	ss.PRICE_NEW 								AS JoiningOriginal,
	CASE
		WHEN sp.TYPE IS NULL THEN 'NORMAL'
		ELSE sp.TYPE
	END											AS SP_TYPE,
	sp.COMENT 									AS sp_COMENT,
	SP.PRICE,
	sp.FROM_DATE 								AS SP_FROM_DATE,
	sp.TO_DATE 									AS SP_TO_DATE,
	sp.APPLIED 									AS SP_APPLIED,
	sub.SUBSCRIPTION_PRICE currentMemberPrice,
		CASE
		WHEN ss.SUBSCRIPTION_TYPE_TYPE = 0 THEN trunc(ss.PRICE_PERIOD / MONTHS_BETWEEN((ss.END_DATE + 1), ss.START_DATE), 2) -- cash pr month
		WHEN ss.SUBSCRIPTION_TYPE_TYPE = 1 THEN ss.PRICE_PERIOD
	END   AS MonthlyPrice,
	prod.PRICE CurrentListPrice,
	pg.NAME 									AS ProductGroup

  
FROM
    PERSONS per
	
LEFT JOIN PERSON_EXT_ATTRS pea_creationdate
ON
    pea_creationdate.PERSONCENTER = per.center
	AND pea_creationdate.PERSONID = per.id
	AND pea_creationdate.NAME = 'CREATION_DATE'

	LEFT JOIN JOURNALENTRIES j
	ON
		j.PERSON_CENTER = per.center
	AND j.PERSON_ID = per.id
	AND j.name = 'Person created'

	

	LEFT JOIN CENTERS cen
ON
	per.CENTER = cen.ID
	
	LEFT JOIN SUBSCRIPTION_SALES ss
	On
	ss.OWNER_CENTER = per.CENTER
	AND ss.OWNER_ID = per.ID
	
	LEFT JOIN EMPLOYEES emp
ON
	ss.EMPLOYEE_CENTER = emp.CENTER
	AND ss.EMPLOYEE_ID = emp.ID	



LEFT JOIN PERSONS emp_person
ON
	emp.PERSONCENTER = emp_person.CENTER
	AND emp.PERSONID = emp_person.ID
	
		LEFT JOIN EMPLOYEES emp2
ON
	j.CREATORCENTER = emp2.CENTER
	AND J.CREATORID = emp2.ID	
	
	LEFT JOIN PERSONS emp_person2
ON
	emp2.PERSONCENTER = emp_person2.CENTER
	AND emp2.PERSONID = emp_person2.ID



	LEFT JOIN PRODUCTS prod
ON
	ss.SUBSCRIPTION_TYPE_CENTER = prod.CENTER
	AND ss.SUBSCRIPTION_TYPE_ID	= prod.ID
	
	LEFT JOIN SUBSCRIPTIONS sub
ON
	ss.SUBSCRIPTION_CENTER = sub.CENTER
	AND ss.SUBSCRIPTION_ID	= sub.id
	
	LEFT JOIN PRODUCT_GROUP pg
ON
	prod.PRIMARY_PRODUCT_GROUP_ID = pg.ID
	
	LEFT JOIN SUBSCRIPTION_PRICE sp
ON
	sub.CENTER = sp.SUBSCRIPTION_CENTER
	AND sub.ID = sp.SUBSCRIPTION_ID

	AND SP.CANCELLED = 0
	--AND SP.APPLIED = 1


LEFT JOIN
    PRIVILEGE_USAGES pu2
ON
    sp.ID = pu2.TARGET_ID
    AND pu2.TARGET_SERVICE = 'SubscriptionPrice'



LEFT JOIN
    CAMPAIGN_CODES cc2
ON
    pu2.CAMPAIGN_CODE_ID = cc2.ID
	
	

	
	
	
WHERE
	per.CENTER IN (:ChosenScope)
	--AND pea_creationdate.TXTVALUE = TO_CHAR(TRUNC(exerpsysdate() -1), 'YYYY-MM-DD')
AND TO_DATE(pea_creationdate.TXTVALUE, 'YYYY-MM-DD') BETWEEN TRUNC(:FROM_date) AND TRUNC(:TO_date)
