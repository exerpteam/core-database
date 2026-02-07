/*
 * Creator: Mikael Ahlberg 
 * SoldCardsDaily
 * mimics the Subscription sales report in Exerp
 * filter on salesdate
 */

SELECT
	ss.OWNER_CENTER || 'p' || ss.OWNER_ID AS PersonId,
	per.fullname,
	pea_mobile.txtvalue AS PhoneMobile,
    CASE  ss.OWNER_TYPE  WHEN 0 THEN 'PRIVATE'  WHEN 1 THEN 'STUDENT'  WHEN 2 THEN 'STAFF'  WHEN 3 THEN 'FRIEND'  WHEN 4 THEN 'CORPORATE'  WHEN 5 THEN 'ONEMANCORPORATE'  WHEN 6 THEN 'FAMILY'  WHEN 7 THEN 'SENIOR'  WHEN 8 THEN 'GUEST'  WHEN 9 THEN 'CONTACT' ELSE 'UNKNOWN' END AS PersonType,
CAST(EXTRACT('year' FROM age(per.birthdate)) AS VARCHAR) AS Age,
	ss.EMPLOYEE_CENTER || 'emp' || ss.EMPLOYEE_ID AS Sales_Employee,
	P.fullname as Salesname,
	CASE ss.SUBSCRIPTION_TYPE_TYPE  WHEN 0 THEN  'CASH'  WHEN 1 THEN  'EFT'  ELSE 'UKNOWN' END as PaymentType,	
	sp.PRICE AS SP_PRICE,	
	ss.SALES_DATE,
	ss.START_DATE,
	prod.NAME AS Product_Name,
	sub.END_DATE AS SUBSCRIPTION_ENDDATE
FROM SUBSCRIPTION_SALES ss
LEFT JOIN PERSONS per
ON
	ss.OWNER_CENTER = per.CENTER
	AND ss.OWNER_ID = per.ID
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

LEFT JOIN EMPLOYEES emp
ON  emp.center = ss.EMPLOYEE_CENTER
AND emp.id = ss.EMPLOYEE_ID

LEFT JOIN PERSONS P

ON  P.center = emp.PERSONCENTER
AND p.id = emp.PERSONID

LEFT JOIN PERSON_EXT_ATTRS pea_mobile

ON
    pea_mobile.PERSONCENTER = per.center
	AND pea_mobile.PERSONID = per.id
	AND pea_mobile.NAME = '_eClub_PhoneSMS'
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
	ss.OWNER_CENTER IN (:Scope)
	AND ss.OWNER_TYPE != 2
    AND SS.SALES_DATE >= cast(:FromDate as date)
   	AND SS.SALES_DATE < cast(:ToDate as date) + 1
	/* let QV filter on product group instead */
	-- AND prod.PRIMARY_PRODUCT_GROUP_ID IN (7, 8, 9, 10, 11, 12, 218, 219, 221, 222)
	-- 7-9 = EFT Subscriptions, 10-12 = CASH subscriptions, 218+222 = EFT campaign subscriptions, 219+221 = CASH campaign subscriptions
	-- 18 = add-on subscriptions, 624 = Lifestyle, 826 = Excluded
