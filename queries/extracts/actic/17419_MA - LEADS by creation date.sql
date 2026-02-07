SELECT
	cen.NAME,
	cen.id,
	j.CREATORCENTER || 'emp' || j.creatorID as creator_Employee,
	per.CENTER || 'p' || per.ID 						AS PersonId,
	per.firstname,
	per.lastname,
	TO_CHAR(trunc(months_between(TRUNC(:CreationDate),per.birthdate)/12)) AS Age,
	pea_creationdate.TXTVALUE						 	AS CreationDate,
 pea_mobile.txtvalue AS PhoneMobile
	
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

LEFT JOIN JOURNALENTRIES j
	ON
		j.PERSON_CENTER = per.center
	AND j.PERSON_ID = per.id
	AND j.name = 'Person created'

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
    per.CENTER NOT IN (152,
                       187,
                       12,
                       183, 9215, 9219, 9220, 9221, 9222, 9223, 9228, 9226, 9227, 9224, 9225, 9229, 9230, 9226, 185, 139, 9232)
	AND cen.COUNTRY = 'SE'
--	AND TO_DATE(pea_creationdate.TXTVALUE, 'YYYY-MM-DD') BETWEEN TRUNC(exerpsysdate() -1) AND TRUNC(exerpsysdate() -1)
	AND TO_DATE(pea_creationdate.TXTVALUE, 'YYYY-MM-DD') = :CreationDate
	AND floor(months_between(exerpsysdate(), "BIRTHDATE") / 12) >= 18
	And per.STATUS IN (0, 6, 9)
	--AND (j.CREATORCENTER, j.CREATORID) NOT IN ((100,6204),(100,15203))
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