-- The extract is extracted from Exerp on 2026-02-08
-- https://clublead.atlassian.net/browse/ST-6954
/**
* Creator: Exerp
* Purpose: List summary of Memberships for a given companyagreement.
*/
SELECT DISTINCT
	comp.FULLNAME                 AS "Company_name",
	comp.center||'p'||comp.ID     AS "Company_ID",
	ca.NAME                       AS "Agreement_Name",
	CASE ca.STATE  WHEN 0 THEN  'Under target'  WHEN 1 THEN  'Active'  WHEN 2 THEN  'Stop new'  WHEN 3 THEN  'Old'  WHEN 4 THEN  'Awaiting activation'  WHEN 5 THEN  'Blocked'  WHEN 6 THEN  'Deleted' END      AS "Agreement_State",
	TO_CHAR(longtodate(minstart.startdate),'YYYY-MM-DD')  AS "Agreement_StartDate",
	TO_CHAR(ca.STOP_NEW_DATE,'YYYY-MM-DD')                AS "Agreement_StopDate",
	counts.Lead_Count,
	counts.Active_Count,
	counts.Inactive_Count,
	prod.NAME                                             AS "Product",
	pp.PRICE_MODIFICATION_NAME                            AS "Rebate_type",
	CASE 
		WHEN pp.PRICE_MODIFICATION_NAME = 'PERCENTAGE_REBATE'
			THEN (1-pp.PRICE_MODIFICATION_AMOUNT) * prod.PRICE
		WHEN pp.PRICE_MODIFICATION_NAME = 'FIXED_REBATE'
			THEN prod.PRICE - pp.PRICE_MODIFICATION_AMOUNT
		WHEN pp.PRICE_MODIFICATION_NAME = 'OVERRIDE'
			THEN pp.PRICE_MODIFICATION_AMOUNT
	END AS "Price_after_Rebate",
	prod.PRICE                                            AS "Normal_Price",
	contact.FULLNAME                                      AS "Contact_Person_Name",
	email.TXTVALUE                                        AS "Contact_Person_Email",
	phone.TXTVALUE                                        AS "Contact_Person_Phone",
	ps.NAME                                               AS "Privilige Set",
	CASE 
		WHEN (position('C' || :center IN ca.AVAILABILITY) > 0) THEN 'Local'  
		ELSE 'Higher' 
  	END                                                   AS "Availability Level" 
FROM
	COMPANYAGREEMENTS ca
JOIN
	PERSONS comp
ON
	ca.CENTER = comp.CENTER
	AND ca.ID = comp.ID 
	AND comp.SEX = 'C'
	AND comp.STATUS NOT IN (5,7,8)
JOIN
	CENTERS c
ON
	comp.center = c.ID
	AND c.COUNTRY = 'SE'
LEFT JOIN
(
	SELECT
		r.RELATIVECENTER,
		r.RELATIVEID,
		MIN(l.ENTRY_START_TIME) startdate
	FROM 
		STATE_CHANGE_LOG l
	JOIN 
    	RELATIVES r
	ON
		r.CENTER = l.CENTER
	AND r.ID = l.ID
	WHERE
    	l.ENTRY_TYPE = 4 
		AND l.STATEID = 1
	GROUP BY r.RELATIVECENTER, r.RELATIVEID 
) minstart
ON
	minstart.relativecenter = ca.CENTER
	AND minstart.relativeid = ca.ID
	LEFT JOIN
	(
		SELECT c.center, c.id, SUM(c.Lead) Lead_Count, SUM(c.Active) Active_Count, SUM(c.Inactive) Inactive_Count
		FROM
		(
			SELECT
   				r.center,
   				r.id, 
			CASE
				WHEN status = 0 THEN 1 
			END AS Lead,
   			CASE
					WHEN status = 1 THEN 1 
			END AS Active,
			CASE
				WHEN status = 2 THEN 1 
			END AS Inactive
		FROM
    		RELATIVES r
		WHERE 
    		r.RTYPE = 2
		) c
		GROUP BY c.center, c.id
	) counts
	ON
		counts.center = ca.CENTER
		AND counts.id = ca.ID

LEFT JOIN 
	PRIVILEGE_GRANTS pg
ON
	pg.GRANTER_CENTER = ca.CENTER
	AND pg.GRANTER_ID = ca.ID
	AND pg.GRANTER_SUBID = ca.SUBID
	AND pg.GRANTER_SERVICE = 'CompanyAgreement'
	AND pg.valid_to IS NULL
LEFT JOIN
	PRIVILEGE_SETS ps
ON
	pg.PRIVILEGE_SET = ps.id             
LEFT JOIN 
	PRODUCT_PRIVILEGES pp
ON
	pp.PRIVILEGE_SET = ps.ID
	AND pp.REF_TYPE = 'GLOBAL_PRODUCT'
LEFT JOIN 
	PRODUCTS prod
ON
	prod.GLOBALID = pp.REF_GLOBALID
	AND prod.CENTER = comp.center
LEFT JOIN
	RELATIVES r_con
ON
	r_con.RTYPE = 7
	AND r_con.CENTER = comp.CENTER
	AND r_con.ID = comp.ID
	AND r_con.STATUS < 2
LEFT JOIN
	PERSONS contact
ON
	contact.CENTER = r_con.RELATIVECENTER
	AND contact.ID = r_con.RELATIVEID
LEFT JOIN
	PERSON_EXT_ATTRS email
ON
	email.PERSONCENTER = contact.CENTER
	AND email.PERSONID = contact.ID
	AND email.NAME = '_eClub_Email'
LEFT JOIN
	PERSON_EXT_ATTRS phone  
ON
	phone.PERSONCENTER = contact.CENTER
	AND phone.PERSONID = contact.ID
	AND phone.NAME = '_eClub_PhoneWork'
CROSS JOIN
(
	SELECT name, 'A'||id AS xid
	FROM
	(
		SELECT a.name,a.id
		FROM AREAS a
		LEFT JOIN AREAS b
			ON a.PARENT = b.id
		LEFT JOIN AREAS c
			ON b.PARENT = c.ID 
		LEFT JOIN AREA_CENTERS ac
			ON ((ac.area = a.id) OR (ac.area = b.id) OR (ac.area = c.id))
		WHERE 
			ac.center = :center
		UNION ALL
		
		SELECT b.name,b.id
		FROM AREAS A
		LEFT JOIN areas B
			ON A.PARENT = b.id
		LEFT JOIN areas c
			ON b.PARENT = C.ID 
		LEFT JOIN area_centers ac
			ON ((ac.area = a.id) OR (ac.area = b.id) OR (ac.area = c.id))
		WHERE 
  			ac.center = :center
		
		UNION ALL
		
		SELECT c.NAME, c.ID
		FROM AREAS A
		LEFT JOIN AREAS B
			ON a.PARENT = b.id 
		LEFT JOIN AREAS c
			ON b.PARENT = c.ID 
		LEFT JOIN AREA_CENTERS ac
			ON ((ac.area = a.id) OR (ac.area = b.id) OR (ac.area = c.id))
		WHERE 
			ac.center = :center
	) t1
	WHERE id IS NOT NULL
) scopes  

WHERE
	((position('C'||:center IN ca.AVAILABILITY) > 0) 
OR
	position(scopes.xid IN ca.AVAILABILITY) > 0)
AND ca.STATE::VARCHAR in (:Agreement_State)
ORDER BY   
	comp.FULLNAME
