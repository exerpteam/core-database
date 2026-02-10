-- The extract is extracted from Exerp on 2026-02-08
--  
SELECT
    P.CENTER,
    P.ID,
 	p.center || 'p' || p.id AS PersonID,  
    DECODE (p.PERSONTYPE, 0,'PRIVATE', 1,'STUDENT', 2,'STAFF', 3,'FRIEND', 4,'CORPORATE', 5,'ONEMANCORPORATE', 6,'FAMILY', 7,'SENIOR', 8,'GUEST','UNKNOWN') AS PERSONTYPE,
    P.FIRSTNAME,
    P.MIDDLENAME,
    P.LASTNAME,
    P.ADDRESS1,
    P.COUNTRY,
    P.ZIPCODE,
    P.CITY,
    P.BIRTHDATE,
    P.SEX,
	pea.txtvalue,
	pea.NAME,
	pea.PERSONID,
	pea_creationdate.txtvalue As CREATION_DATE



FROM
    PERSONS P


LEFT JOIN  PERSON_EXT_ATTRS pea

on pea.PERSONID = p.id
and pea.personcenter = p.center 

LEFT JOIN PERSON_EXT_ATTRS pea_creationdate
ON
    pea_creationdate.PERSONCENTER = p.center
AND pea_creationdate.PERSONID = p.id
AND pea_creationdate.NAME = 'CREATION_DATE'

Where pea.txtvalue = :EA_ID
AND pea.name = 'lead_campaign_sweden'

And p.center IN (:scope)

