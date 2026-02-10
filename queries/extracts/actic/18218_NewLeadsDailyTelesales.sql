-- The extract is extracted from Exerp on 2026-02-08
--  
SELECT
	cen.NAME,
	cen.id,
	per.CENTER || 'p' || per.ID 						AS PersonId,
	per.firstname,
	per.lastname,
	TO_CHAR(trunc(months_between(TRUNC(exerpsysdate()), per.birthdate)/12)) AS Age,
	pea_creationdate.TXTVALUE						 	AS CreationDate,
	REGEXP_REPLACE(
         REGEXP_REPLACE(
           pea_mobile.txtvalue,
           '^\+46|\D',
           ''
         ),
         '^0', '' ) AS PhoneMobile
	
FROM
    PERSONS per
	
LEFT JOIN PERSON_EXT_ATTRS pea_creationdate
ON
    pea_creationdate.PERSONCENTER = per.center
	AND pea_creationdate.PERSONID = per.id
	AND pea_creationdate.NAME = 'CREATION_DATE'

LEFT JOIN PERSON_EXT_ATTRS pea_mobile
ON
    pea_mobile.PERSONCENTER = per.center
	AND pea_mobile.PERSONID = per.id
	AND pea_mobile.NAME = '_eClub_PhoneSMS'

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
	per.CENTER NOT IN (152, 187, 8, 21, 56, 85, 6, 53, 12, 102, 183)
	AND cen.COUNTRY = 'SE'
--	AND TO_DATE(pea_creationdate.TXTVALUE, 'YYYY-MM-DD') BETWEEN TRUNC(exerpsysdate() -1) AND TRUNC(exerpsysdate() -1)

	AND floor(months_between(exerpsysdate(), "BIRTHDATE") / 12) >= 18
	And per.STATUS IN (0, 6, 9)
	AND pea_creationdate.TXTVALUE = TO_CHAR(TRUNC(exerpsysdate() -1), 'YYYY-MM-DD')
	AND 
	(
		TO_DATE(pea_creationdate.TXTVALUE, 'YYYY-MM-DD') < first_sub.MinSubSalesDate 
		OR first_sub.MinSubSalesDate IS NULL
	)
	AND 
	(
		TO_DATE(pea_creationdate.TXTVALUE, 'YYYY-MM-DD') < first_sub.MinSubStartDate
		OR first_sub.MinSubStartDate IS NULL
	)
ORDER BY
	cen.EXTERNAL_ID