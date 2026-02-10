-- The extract is extracted from Exerp on 2026-02-08
--  
/* QV2NewLeadsDaily Manual */
/*
 - Ändra i leads scriptet så att det enbart tar bort de fyra riktiga kategorierna av medlemskap, 
 - lägg till  namn på övriga medlemskap 
 - lägg till personstatus. ICA kampanj 1v skall fortfarande ses som lead
*/

SELECT
	cen.COUNTRY,
	cen.EXTERNAL_ID 									AS Cost,
j.CREATORCENTER || 'emp' || j.creatorID as creator_Employee,
	per.CENTER || 'p' || per.ID 						AS PersonId,

--  DECODE (per.STATUS, 0,'LEAD', 1,'ACTIVE', 2,'INACTIVE', 3,'TEMPORARY INACTIVE', 4,'TRANSFERED', 5,'DUPLICATE', 6, 'PROSPECT',7,'DELETED',9,'CONTACT','UNKNOWN')  AS PERSONSTATUS,
    DECODE (scl_pstatus.STATEID, 0,'LEAD', 1,'ACTIVE', 2,'INACTIVE', 3,'TEMPORARY INACTIVE', 4,'TRANSFERED', 5,'DUPLICATE', 6, 'PROSPECT',7,'DELETED',9,'CONTACT', 'UNKNOWN')  AS PERSONSTATUS,
	TO_CHAR(trunc(months_between(TRUNC(:MemberBaseDate), per.birthdate)/12)) AS Age,
	pea_creationdate.TXTVALUE						 	AS CreationDate,
	CASE
		WHEN first_sub.PG_Id IN (7, 8, 9, 10, 11, 12, 218, 219, 221, 222) THEN NULL
		ELSE first_sub.NAME
	END 												AS Product_Name,
	CASE
		WHEN first_sub.PG_Id IN (7, 8, 9, 10, 11, 12, 218, 219, 221, 222) THEN NULL
		ELSE first_sub.GLOBALID
	END 												AS Global_Id,
	CASE
		WHEN first_sub.PG_Id IN (7, 8, 9, 10, 11, 12, 218, 219, 221, 222) THEN NULL
		ELSE first_sub.PG_Name
	END 												AS Product_Group
--	first_sub.NAME										AS Product_Name,
--	first_sub.GLOBALID									AS Global_Id,
--	PG_Name												AS Product_Group
/*
	CASE
		WHEN first_sub.MinSubSalesDate <= first_sub.MinSubStartDate
		THEN first_sub.MinSubSalesDate
		WHEN first_sub.MinSubSalesDate > first_sub.MinSubStartDate
		THEN first_sub.MinSubStartDate
	END 												AS LowestSubDate,

	first_sub.MinSubSalesDate							AS FirstSubSalesDate,
	first_sub.MinSubStartDate							AS FirstSubStartDate
*/
FROM
    PERSONS per
	
LEFT JOIN PERSON_EXT_ATTRS pea_creationdate
ON
    pea_creationdate.PERSONCENTER = per.center
	AND pea_creationdate.PERSONID = per.id
	AND pea_creationdate.NAME = 'CREATION_DATE'
LEFT JOIN CENTERS cen
ON
	per.CENTER = cen.ID
-----------------------------------------------------------------	
-- personstatus at the time choosen
-- added by MB
LEFT JOIN STATE_CHANGE_LOG scl_pstatus
ON
    per.CENTER = scl_pstatus.CENTER
    AND per.ID = scl_pstatus.ID
    AND scl_pstatus.ENTRY_TYPE = 1
    AND longToDate(scl_pstatus.ENTRY_START_TIME) <= (:MemberBaseDate +1) -- Date
    AND
        (scl_pstatus.ENTRY_END_TIME IS NULL
        OR longToDate(scl_pstatus.ENTRY_END_TIME) > (:MemberBaseDate +1))
-----------------------------------------------------------------	


LEFT JOIN JOURNALENTRIES j
	ON
		j.PERSON_CENTER = per.center
	AND j.PERSON_ID = per.id
	AND j.name = 'Person created'
	
LEFT JOIN EMPLOYEES emp2
ON
	j.CREATORCENTER = emp2.CENTER
	AND J.CREATORID = emp2.ID	
	
	LEFT JOIN PERSONS emp_person2
ON
	emp2.PERSONCENTER = emp_person2.CENTER
	AND emp2.PERSONID = emp_person2.ID


LEFT JOIN
	(
		SELECT
			ss.OWNER_CENTER,
			ss.OWNER_ID,
			prod.NAME,
			prod.GLOBALID,
			pg.NAME AS PG_Name,
			pg.ID AS PG_Id,
			MIN(ss.SALES_DATE) AS MinSubSalesDate,
			MIN(ss.START_DATE) AS MinSubStartDate
		
		FROM
			SUBSCRIPTION_SALES ss
		LEFT JOIN PRODUCTS prod
		ON
			prod.CENTER = ss.SUBSCRIPTION_TYPE_CENTER
			AND prod.ID = ss.SUBSCRIPTION_TYPE_ID
		LEFT JOIN PRODUCT_GROUP pg
		ON
			prod.PRIMARY_PRODUCT_GROUP_ID = pg.ID
		GROUP BY
			ss.OWNER_CENTER,
			ss.OWNER_ID,
			prod.NAME,
			prod.GLOBALID,
			pg.NAME,
			pg.ID
	) first_sub
ON
	first_sub.OWNER_CENTER = per.CENTER
	AND first_sub.OWNER_ID = per.ID
	
WHERE
	per.CENTER IN (:ChosenScope)	
--	AND TO_DATE(pea_creationdate.TXTVALUE, 'YYYY-MM-DD') BETWEEN TRUNC(exerpsysdate() -1) AND TRUNC(exerpsysdate() -1)
	AND TO_DATE(pea_creationdate.TXTVALUE, 'YYYY-MM-DD') = :MemberBaseDate
	
	AND 
		( -- person creation date should be less then subscription salesdate
			TO_DATE(pea_creationdate.TXTVALUE, 'YYYY-MM-DD') < 
			(CASE	
				WHEN first_sub.PG_Id IN (7, 8, 9, 10, 11, 12, 218, 219, 221, 222)
				THEN first_sub.MinSubSalesDate 
				
				-- ELSE first_sub.MinSubSalesDate 
				ELSE TRUNC(exerpsysdate() +1)
			END)
			OR first_sub.MinSubSalesDate IS NULL
		)

	AND 
		( -- person creation date should be less then subscription startdate
			TO_DATE(pea_creationdate.TXTVALUE, 'YYYY-MM-DD') < 
			(CASE	
				WHEN first_sub.PG_Id IN (7, 8, 9, 10, 11, 12, 218, 219, 221, 222)
				THEN first_sub.MinSubStartDate
				
				-- ELSE first_sub.MinSubStartDate 
				ELSE TRUNC(exerpsysdate() +1)
			END)
			OR first_sub.MinSubStartDate IS NULL
		)
	
	-- Product groups
	-- 7-9 = EFT Subscriptions, 10-12 = CASH subscriptions, 218+222 = EFT campaign subscriptions, 219+221 = CASH campaign subscriptions
	-- 18 = add-on subscriptions, 624 = Lifestyle, 826 = Excluded
	
ORDER BY
	cen.EXTERNAL_ID