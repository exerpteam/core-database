/**
* Creator: Mikael Ahlberg
* Purpose: List non signedup members that became leads in given period. Published as report to clubmanager.
*/
SELECT
    cen.NAME,
	j.CREATORCENTER || 'emp' || j.creatorID as creator_Employee,
	emp_person2.FIRSTNAME || ' ' || emp_person2.LASTNAME	AS creator_Name,
    per.CENTER || 'p' || per.ID AS PersonId,
	CASE  per.PERSONTYPE  WHEN 0 THEN 'PRIVATE'  WHEN 1 THEN 'STUDENT'  WHEN 2 THEN 'STAFF'  WHEN 3 THEN 'FRIEND'  WHEN 4 THEN 'CORPORATE'  WHEN 5 THEN 'ONEMANCORPORATE'  WHEN 6 THEN 'FAMILY'  WHEN 7 THEN 'SENIOR'  WHEN 8 THEN 'GUEST' ELSE 'UNKNOWN' END AS PersonType,
    per.fullname,
	(TRUNC(months_between(TRUNC(current_timestamp),per.birthdate)/12))::varchar                  AS Age,
    pea_creationdate.TXTVALUE                                                       AS CreationDate,
    pea_mobile.txtvalue AS PhoneMobile
FROM
    PERSONS per


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
    PERSON_EXT_ATTRS pea_creationdate
ON
    pea_creationdate.PERSONCENTER = per.center
	AND pea_creationdate.PERSONID = per.id
	AND pea_creationdate.NAME = 'CREATION_DATE'
LEFT JOIN
    PERSON_EXT_ATTRS pea_mobile
ON
    pea_mobile.PERSONCENTER = per.center
	AND pea_mobile.PERSONID = per.id
	AND pea_mobile.NAME = '_eClub_PhoneSMS'
LEFT JOIN
    CENTERS cen
ON
    per.CENTER = cen.ID
WHERE
    per.CENTER IN (:Scope)
AND TO_DATE(pea_creationdate.TXTVALUE, 'YYYY-MM-DD') BETWEEN TRUNC((:FROM_date)::date) AND TRUNC((:TO_date)::date)
AND per.STATUS IN (0, 6, 9) -- Lead, Prospect, Contact
ORDER BY
    cen.EXTERNAL_ID
