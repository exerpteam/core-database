-- The extract is extracted from Exerp on 2026-02-08
--  
/*
 * LeadsConversionDaily
 */
-- TODO
--
WITH
    PARAMS AS
    (
        SELECT
                /*+ materialize */
				TRUNC(to_date(getcentertime(c.id), 'YYYY-MM-DD HH24:MI') - (12 * 7) - 1) AS fromDate,
				TRUNC(to_date(getcentertime(c.id), 'YYYY-MM-DD HH24:MI') - 1) AS toDate,
                c.ID AS CenterID
        FROM CENTERS c
        JOIN COUNTRIES co ON c.COUNTRY = co.ID

    )
SELECT
	cen.COUNTRY,
	cen.EXTERNAL_ID 									AS Cost,
	per.CENTER || 'p' || per.ID 						AS PersonId,
	CAST(EXTRACT('year' FROM age(per.birthdate)) AS VARCHAR)                AS Age,
	TO_DATE(pea_creationdate.TXTVALUE, 'YYYY-MM-DD') 	AS CreationDate,

	CASE
		WHEN first_sub.MinSubSalesDate <= first_sub.MinSubStartDate
		THEN first_sub.MinSubSalesDate
		WHEN first_sub.MinSubSalesDate > first_sub.MinSubStartDate
		THEN first_sub.MinSubStartDate
	END 												AS LowestSubDate,

	first_sub.MinSubSalesDate							AS FirstSubSalesDate,
	first_sub.MinSubStartDate							AS FirstSubStartDate
	
FROM
    PERSONS per
JOIN PARAMS params ON params.CenterID = per.CENTER
LEFT JOIN PERSON_EXT_ATTRS pea_creationdate
ON
    pea_creationdate.PERSONCENTER = per.center
	AND pea_creationdate.PERSONID = per.id
	AND pea_creationdate.NAME = 'CREATION_DATE'
LEFT JOIN CENTERS cen
ON
	per.CENTER = cen.ID
LEFT JOIN
	(
		SELECT
			ss.OWNER_CENTER,
			ss.OWNER_ID,
			MIN(ss.SALES_DATE) AS MinSubSalesDate,
			MIN(ss.START_DATE) AS MinSubStartDate
		
		FROM
			SUBSCRIPTION_SALES ss
		GROUP BY
			ss.OWNER_CENTER,
			ss.OWNER_ID
	) first_sub
ON
	first_sub.OWNER_CENTER = per.CENTER
	AND first_sub.OWNER_ID = per.ID
	
WHERE
	per.CENTER IN (:ChosenScope)
	AND TO_DATE(pea_creationdate.TXTVALUE, 'YYYY-MM-DD') BETWEEN params.fromDate AND params.toDate
	AND first_sub.OWNER_CENTER IS NOT NULL
	/*
	AND TO_DATE(pea_creationdate.TXTVALUE, 'YYYY-MM-DD') BETWEEN fromDate AND toDate
	*/
	-- make sure that person is created atleast one day before subscription is sold
	AND 
	(
		TO_DATE(pea_creationdate.TXTVALUE, 'YYYY-MM-DD') < first_sub.MinSubSalesDate 
		OR first_sub.MinSubSalesDate IS NULL
	)
	/*
	-- smake sure that person is created atleast one day before startdate of subscription
	AND 
	(
		TO_DATE(pea_creationdate.TXTVALUE, 'YYYY-MM-DD') < first_sub.MinSubStartDate
		OR first_sub.MinSubStartDate IS NULL
	)
	*/
ORDER BY
	cen.EXTERNAL_ID
