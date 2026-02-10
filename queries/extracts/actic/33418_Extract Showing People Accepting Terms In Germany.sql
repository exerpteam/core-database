-- The extract is extracted from Exerp on 2026-02-08
--  
SELECT
    c.name,
 	p.center || 'p' || p.id AS PersonID,  
    DECODE (p.PERSONTYPE, 0,'PRIVATE', 1,'STUDENT', 2,'STAFF', 3,'FRIEND', 4,'CORPORATE', 5,'ONEMANCORPORATE', 6,'FAMILY', 7,'SENIOR', 8,'GUEST','UNKNOWN') AS PERSONTYPE,
    DECODE(P.STATUS, 0,'Lead', 1,'Active', 2,'Inactive', 3,'Temporary inactive', 4,'Transferred', 5,'Duplicate', 6,'Prospect', 7,'Deleted', 8, 'Anonimized', 9, 'Contact', 'Unknown') AS STATUS,
	P.FIRSTNAME,
    P.LASTNAME,
	pea_creationdate.txtvalue As CREATION_DATE,
	pea_term.NAME,
	pea_term.txtvalue
	

FROM
    PERSONS P


JOIN Centers c
ON
p.center = c.id 

LEFT JOIN PERSON_EXT_ATTRS pea_creationdate
ON
    pea_creationdate.PERSONCENTER = p.center
AND pea_creationdate.PERSONID = p.id
AND pea_creationdate.NAME = 'CREATION_DATE'
	
	
LEFT JOIN PERSON_EXT_ATTRS pea_term
ON
    pea_term.PERSONCENTER = p.center
AND pea_term.PERSONID = p.id




WHERE p.center IN (:scope)
AND pea_term.NAME = 'ACCEPTLEADTERMS'
AND pea_term.txtvalue = '1'