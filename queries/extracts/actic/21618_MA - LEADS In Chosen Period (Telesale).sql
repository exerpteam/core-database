-- The extract is extracted from Exerp on 2026-02-08
-- Dedicated to TeleSale
Leads created by API AND APP user is exluded.
SELECT
    cen.NAME,
    cen.id,
	j.CREATORCENTER || 'emp' || j.creatorID as creator_Employee,
    per.CENTER || 'p' || per.ID AS PersonId,
    per.firstname,
    per.lastname,
	per.status,
    TO_CHAR(TRUNC(months_between(TRUNC(exerpsysdate()),per.birthdate)/12))                   AS Age,
    pea_creationdate.TXTVALUE                                                       AS CreationDate,
    --REGEXP_REPLACE( REGEXP_REPLACE( pea_mobile.txtvalue, '^\+46|\D', '' ), --'^0', '' )AS PhoneMobile
pea_mobile.txtvalue AS PhoneMobile

FROM
    PERSONS per
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

LEFT JOIN JOURNALENTRIES j
	ON
		j.PERSON_CENTER = per.center
	AND j.PERSON_ID = per.id
	AND j.name = 'Person created'


LEFT JOIN
    CENTERS cen
ON
    per.CENTER = cen.ID
WHERE
    per.CENTER NOT IN (152,
                       187,
                       12,
                       183, 9215, 9219, 9220, 9221, 9222, 9223, 9228, 9226, 9227, 9224, 9225, 9229, 9230, 9226, 185, 139, 9232)
AND cen.COUNTRY = 'SE'
AND TO_DATE(pea_creationdate.TXTVALUE, 'YYYY-MM-DD') BETWEEN TRUNC(:FROM_date) AND TRUNC(:TO_date)
AND floor(months_between(exerpsysdate(), "BIRTHDATE") / 12) >= 18
AND per.STATUS IN (0, 6, 9)
--AND (j.CREATORCENTER, j.CREATORID) NOT IN ((100,6204),(100,15203))
ORDER BY
    cen.EXTERNAL_ID