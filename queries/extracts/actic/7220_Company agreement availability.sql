/**
* Creator: Exerp
* Purpose: List availabilities by companyagreements.
* 
*/
SELECT
	ca.availability,
	c.country,
	company.LASTNAME AS companyname,
	ca.NAME AS agreementname,
	pro.NAME AS product,
	pro.PRICE AS normal_price,
	CASE
		WHEN pp.PRICE_MODIFICATION_NAME = 'FIXED_REBATE'
		THEN pro.PRICE - pp.PRICE_MODIFICATION_AMOUNT
		WHEN pp.PRICE_MODIFICATION_NAME = 'OVERRIDE'
		THEN pp.PRICE_MODIFICATION_AMOUNT
		WHEN pp.PRICE_MODIFICATION_NAME = 'PERCENTAGE_REBATE'
		THEN pro.price * (1 - pp.PRICE_MODIFICATION_AMOUNT)
		WHEN pp.PRICE_MODIFICATION_NAME = 'FREE'
		THEN 0
		ELSE pro.PRICE
	END AS REBATE_PRICE,
	pp.PRICE_MODIFICATION_NAME AS REBATE_TYPE,
	TO_CHAR(ca.STOP_NEW_DATE, 'YYYY-MM-DD') AS END_DATE,
	COUNT (DISTINCT(ansatte.center||'p'||ansatte.id)) AS count_pr_agreement
FROM
	COMPANYAGREEMENTS ca

JOIN PERSONS company
	ON company.center = ca.center
	AND company.id = ca.id
	AND company.sex = 'C'

LEFT JOIN PRIVILEGE_GRANTS pg
	ON pg.GRANTER_CENTER = ca.CENTER
	AND pg.GRANTER_ID = ca.ID
	AND pg.GRANTER_SUBID = ca.SUBID
	AND pg.GRANTER_SERVICE = 'CompanyAgreement'

LEFT JOIN PRIVILEGE_SETS ps
	ON ps.ID = pg.PRIVILEGE_SET

LEFT JOIN PRODUCT_PRIVILEGES pp
	ON pp.PRIVILEGE_SET = ps.ID
	AND pp.REF_TYPE = 'GLOBAL_PRODUCT'

JOIN relatives rel
	ON rel.RELATIVECENTER = ca.CENTER
	AND rel.RELATIVEID = ca.ID
	AND rel.RELATIVESUBID = ca.SUBID
	AND rel.RTYPE = 3

JOIN persons ansatte
	ON rel.CENTER = ansatte.CENTER
	AND rel.ID = ansatte.ID
	AND rel.status = 1

JOIN subscriptions s
	ON rel.CENTER = s.OWNER_CENTER
	AND rel.ID = s.owner_id

JOIN subscriptiontypes st
	ON  s.subscriptiontype_center = st.center 
	AND s.subscriptiontype_id = st.id

JOIN products pro
	ON st.center = pro.center
	AND st.id = pro.id

JOIN centers c
	ON s.owner_center = c.id

WHERE
	(
		(ca.STOP_NEW_DATE IS NULL)
		OR (ca.STOP_NEW_DATE  > TO_DATE(TO_CHAR(exerpsysdate(),'yyyy-mm-dd'),'yyyy-mm-dd') )
	)
	AND ca.state IN (1)   /*agreement active*/
	AND s.state IN (2)   /*subscription active*/
	AND c.country IN (:country)

GROUP BY
	ca.availability,
	c.country,
	company.LASTNAME,
	ca.NAME,
	pro.NAME,
	pro.PRICE,
	pro.PRICE - pp.PRICE_MODIFICATION_AMOUNT,
	pp.PRICE_MODIFICATION_AMOUNT,
	pro.price * (1 - pp.PRICE_MODIFICATION_AMOUNT),
	pro.PRICE,
	pp.PRICE_MODIFICATION_NAME,
	ca.STOP_NEW_DATE

ORDER BY
	company.LASTNAME,
	ca.NAME,
	pro.name,
	pro.price