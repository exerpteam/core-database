SELECT
	cen.NAME,
	cen.id,
	j.CREATORCENTER || 'emp' || j.creatorID as creator_Employee,
	emp_person2.FIRSTNAME || ' ' || emp_person2.LASTNAME	AS creator_Name,
	per.CENTER || 'p' || per.ID 						AS PersonId,
	 CASE per.STATUS WHEN 0 THEN 'LEAD' WHEN 1 THEN 
        'ACTIVE' WHEN 2 THEN 'INACTIVE' WHEN 3 THEN 'TEMPORARY 
        INACTIVE' WHEN 4 THEN 'TRANSFERRED' WHEN 5 THEN 'DUPLICATE' 
        WHEN 6 THEN 'PROSPECT' WHEN 7 THEN 'DELETED' WHEN 8 THEN 
        'ANONIMIZED' WHEN 9 THEN 'CONTACT' ELSE 'UNKNOWN' END AS 
        Person_STATUS,
	per.firstname,
	per.lastname,
	pea_email.txtvalue                                           AS Email,
	pea_creationdate.TXTVALUE						 	AS CreationDate,
			pea_id.name 								AS EA_value
	
FROM
    PERSONS per
	
LEFT JOIN PERSON_EXT_ATTRS pea_creationdate
ON
    pea_creationdate.PERSONCENTER = per.center
	AND pea_creationdate.PERSONID = per.id
	AND pea_creationdate.NAME = 'CREATION_DATE'
	
	LEFT JOIN PERSON_EXT_ATTRS pea_email
ON
    pea_email.PERSONCENTER = per.center
	AND pea_email.PERSONID = per.id
	AND pea_email.name = '_eClub_Email'

LEFT JOIN PERSON_EXT_ATTRS pea_mobile
ON
    pea_mobile.PERSONCENTER = per.center
	AND pea_mobile.PERSONID = per.id
	AND pea_mobile.NAME = '_eClub_PhoneSMS'

LEFT JOIN PERSON_EXT_ATTRS pea_id
ON
    pea_id.PERSONCENTER = per.center
	AND pea_id.PERSONID = per.id
	AND pea_id.name = 'WALKINLEAD'


LEFT JOIN JOURNALENTRIES j
	ON
		j.PERSON_CENTER = per.center
	AND j.PERSON_ID = per.id
--	AND j.name = 'Person created'
	
	LEFT JOIN EMPLOYEES emp2
ON
	j.CREATORCENTER = emp2.CENTER
	AND J.CREATORID = emp2.ID	
	
	LEFT JOIN PERSONS emp_person2
ON
	emp2.PERSONCENTER = emp_person2.CENTER
	AND emp2.PERSONID = emp_person2.ID

LEFT JOIN CENTERS cen
ON
	per.CENTER = cen.ID

	
WHERE
    per.CENTER  IN (:Scope)
	--AND TO_DATE(pea_creationdate.TXTVALUE, 'YYYY-MM-DD') BETWEEN TRUNC(exerpsysdate() -1) AND TRUNC(exerpsysdate() -1)
	--AND TO_DATE(pea_creationdate.TXTVALUE, 'YYYY-MM-DD') = CreationDate
	AND TO_DATE(pea_creationdate.TXTVALUE, 'YYYY-MM-DD') BETWEEN TRUNC(:FROM_date) AND TRUNC(:TO_date)
	And per.STATUS IN (0, 6, 9)
	--AND (j.CREATORCENTER, j.CREATORID) NOT IN ((100,6204),(100,15203))
	
ORDER BY
	cen.EXTERNAL_ID