-- The extract is extracted from Exerp on 2026-02-08
--  
/* QV2SoldCardsSalesdatePT Manual
 *
 * mimics the Subscription sales report in Exerp
 * filter on: salesdate, personal traing product groups, includes staff
 */

SELECT
	ss.ID,
	cen.COUNTRY,
	cen.EXTERNAL_ID AS Cost,
	ss.OWNER_CENTER || 'p' || ss.OWNER_ID AS PersonId,
    DECODE (ss.OWNER_TYPE, 0,'PRIVATE', 1,'STUDENT', 2,'STAFF', 3,'FRIEND', 4,'CORPORATE', 5,'ONEMANCORPORATE', 6,'FAMILY', 7,'SENIOR', 8,'GUEST','UNKNOWN') AS PersonType,
	TO_CHAR(trunc(months_between(TRUNC(:MemberBaseDate), per.birthdate)/12)) AS Age,
	ss.EMPLOYEE_CENTER || 'emp' || ss.EMPLOYEE_ID AS Sales_Employee,
	emp_person.FIRSTNAME || ' ' || emp_person.LASTNAME AS EmployeeName,
	CASE
		WHEN ss.COMPANY_CENTER IS NOT NULL THEN ss.COMPANY_CENTER || 'p' || ss.COMPANY_ID
		ELSE NULL
	END 										AS Company,
    COMPANY.LASTNAME                   			AS COMPANY_NAME,
	CASE
		WHEN ss.COMPANY_CENTER IS NOT NULL THEN CA.NAME
		ELSE NULL
	END 										AS CA_COMPANY_AGREEMENT_NAME,
    DECODE(ss.SUBSCRIPTION_TYPE_TYPE, 0, 'CASH', 1, 'EFT', 'UKNOWN') as PaymentType,
	/* CASE
		WHEN ss.CANCELLATION_DATE IS NOT NULL THEN 'CANCEL'
		WHEN ss.TERMINATION_DATE IS NOT NULL THEN 'TERMINATION'
		ELSE DECODE(ss.TYPE, 1, 'NEW', 2, 'EXTENSION', 3, 'CHANGE')
	END AS SalesType, */
	CASE
		WHEN ss.TYPE = 1
		THEN 1
		ELSE 0
	END 										AS New,
	CASE
		WHEN ss.TYPE = 2
		THEN 1
		ELSE 0
	END 										AS Extension,
	CASE
		WHEN ss.TYPE = 3
		THEN 1
		ELSE 0
	END 										AS Change,
	CASE
		WHEN ss.CANCELLATION_DATE IS NOT NULL THEN 1
		ELSE 0
	END											AS Cancel,
	CASE
		WHEN ss.TERMINATION_DATE IS NOT NULL THEN 1
		ELSE 0
	END 										AS Termination,
	ss.PRICE_NEW 								AS JoiningOriginal,
	ss.PRICE_NEW_SPONSORED 						AS JoiningSponsored,
	ss.PRICE_NEW_DISCOUNT 						AS JoiningRebate,
	ss.PRICE_INITIAL 							AS InitialOriginal,
	ss.PRICE_INITIAL_SPONSORED 					AS InitialSponsored,
	ss.PRICE_INITIAL_DISCOUNT					AS InitialRebate,
	ss.PRICE_PERIOD 							AS InitialCustomer,
-------------------------------------------------
-- calculate cash price	per month
	CASE
		WHEN ss.SUBSCRIPTION_TYPE_TYPE = 0 THEN trunc(ss.PRICE_PERIOD / MONTHS_BETWEEN((ss.END_DATE + 1), ss.START_DATE), 2) -- cash pr month
		WHEN ss.SUBSCRIPTION_TYPE_TYPE = 1 THEN ss.PRICE_PERIOD
	END   										AS MonthlyPrice,
	
	CASE WHEN sp.PRICE IS NULL 
		 THEN CASE
				WHEN ss.SUBSCRIPTION_TYPE_TYPE = 0 THEN trunc(ss.PRICE_PERIOD / MONTHS_BETWEEN((ss.END_DATE + 1), ss.START_DATE), 2) -- cash pr month
				WHEN ss.SUBSCRIPTION_TYPE_TYPE = 1 THEN ss.PRICE_PERIOD
			  END
		 ELSE CASE
				WHEN ss.SUBSCRIPTION_TYPE_TYPE = 0 THEN trunc(sp.PRICE / MONTHS_BETWEEN((ss.END_DATE + 1), ss.START_DATE), 2) -- cash pr month
				WHEN ss.SUBSCRIPTION_TYPE_TYPE = 1 THEN sp.PRICE
			  END		
	END											AS SP_PRICE,
-------------------------------------------------
	-- sp.PRICE AS SP_PRICE,
	CASE
		WHEN sp.TYPE IS NULL THEN 'NORMAL'
		ELSE sp.TYPE
	END											AS SP_TYPE,
--	sp.TYPE AS SP_TYPE,
	sp.FROM_DATE 								AS SP_FROM_DATE,
	sp.TO_DATE 									AS SP_TO_DATE,
	sp.APPLIED 									AS SP_APPLIED,
--	sp.COMENT AS sp_COMENT,
	ss.CREDITED,
	ss.BINDING_DAYS,
	ss.SALES_DATE,
	ss.START_DATE,
	CASE
		WHEN ss.END_DATE IS NULL
		THEN sub.END_DATE
		ELSE ss.END_DATE
	END 										AS End_Date,
--	ss.END_DATE AS old_end_date,
	ss.SUBSCRIPTION_CENTER || 'ss' || ss.SUBSCRIPTION_ID AS Subscription,
	ss.CANCELLATION_DATE,
	ss.TERMINATION_DATE,
	CASE
		WHEN ss.CANCELLATION_DATE IS NOT NULL OR ss.TERMINATION_DATE IS NOT NULL
		THEN ss.CANCELLATION_EMPLOYEE_CENTER || 'emp' || ss.CANCELLATION_EMPLOYEE_ID
		ELSE NULL
	END 										AS Cancellation_Employee,
	prod.NAME 									AS Product_Name,
	prod.GLOBALID 								AS Global_Id,
	pg.NAME 									AS ProductGroup

FROM SUBSCRIPTION_SALES ss
LEFT JOIN PERSONS per
ON
	ss.OWNER_CENTER = per.CENTER
	AND ss.OWNER_ID = per.ID
---------
LEFT JOIN EMPLOYEES emp
ON
	ss.EMPLOYEE_CENTER = emp.CENTER
	AND ss.EMPLOYEE_ID = emp.ID	
LEFT JOIN PERSONS emp_person
ON
	emp.PERSONCENTER = emp_person.CENTER
	AND emp.PERSONID = emp_person.ID
------------
LEFT JOIN SUBSCRIPTIONS sub
ON
	ss.SUBSCRIPTION_CENTER = sub.CENTER
	AND ss.SUBSCRIPTION_ID	= sub.id

LEFT JOIN PRODUCTS prod
ON
	ss.SUBSCRIPTION_TYPE_CENTER = prod.CENTER
	AND ss.SUBSCRIPTION_TYPE_ID	= prod.ID
LEFT JOIN PRODUCT_GROUP pg
ON
	prod.PRIMARY_PRODUCT_GROUP_ID = pg.ID
LEFT JOIN SUBSCRIPTION_PRICE sp
ON
	sub.CENTER = sp.SUBSCRIPTION_CENTER
	AND sub.ID = sp.SUBSCRIPTION_ID
    AND sp.FROM_DATE <= sub.START_DATE
    AND
        (sp.TO_DATE IS NULL
        OR sp.TO_DATE >= sub.START_DATE)
	AND SP.CANCELLED = 0
LEFT JOIN CENTERS cen
ON
	ss.OWNER_CENTER = cen.ID
-------------------------------------------------------------
-- persons linked to company and agreement at the time of sale
LEFT JOIN
	(
		SELECT
			scl_rel.CENTER,
			scl_rel.ID,
			scl_rel.ENTRY_START_TIME,
			scl_rel.ENTRY_END_TIME,
			companyAgrRel.RELATIVECENTER,
			companyAgrRel.RELATIVEID,
			companyAgrRel.RELATIVESUBID
		FROM STATE_CHANGE_LOG scl_rel
		INNER JOIN RELATIVES companyAgrRel
		ON
			scl_rel.CENTER = companyAgrRel.CENTER
			AND scl_rel.ID = companyAgrRel.ID
			AND scl_rel.SUBID = companyAgrRel.SUBID
			AND companyAgrRel.RTYPE = 3
		WHERE
			scl_rel.ENTRY_TYPE = 4
			AND scl_rel.STATEID != 3
	) compRel
ON
	ss.OWNER_CENTER = compRel.CENTER
    AND ss.OWNER_ID = compRel.ID
    AND compRel.ENTRY_START_TIME <= sub.CREATION_TIME
    AND
        (compRel.ENTRY_END_TIME IS NULL
        OR compRel.ENTRY_END_TIME >= sub.CREATION_TIME)

LEFT JOIN COMPANYAGREEMENTS ca
ON
    ca.CENTER = compRel.RELATIVECENTER
    AND ca.ID = compRel.RELATIVEID
    AND ca.SUBID = compRel.RELATIVESUBID
	
LEFT JOIN PERSONS company
ON
    company.CENTER = ca.CENTER
    AND company.ID = ca.id
    AND company.sex = 'C'
-------------------------------------------------------------
WHERE
	ss.OWNER_CENTER IN (:ChosenScope)
	AND ss.SALES_DATE = (:MemberBaseDate)
	-- AND ss.SALES_DATE BETWEEN TRUNC(exerpsysdate() -1) AND TRUNC(exerpsysdate() -1)
	-- AND ss.OWNER_TYPE != 2 -- include staff
	/* let QV filter on product group instead */
	AND prod.PRIMARY_PRODUCT_GROUP_ID IN (1224, 1227, 1824, 2224, 2225, 2226, 6624, 6625, 6626, 10224, 10225, 10226, 10825, 3224, 3625, 5224, 5227)
	-- Product groups
	-- 7-9 = EFT Subscriptions, 10-12 = CASH subscriptions, 218+222 = EFT campaign subscriptions, 219+221 = CASH campaign subscriptions
	-- 18 = add-on subscriptions, 624 = Lifestyle, 826 = Excluded, 1224, 1227, 1824, 2224-2226 = Personal Training
	