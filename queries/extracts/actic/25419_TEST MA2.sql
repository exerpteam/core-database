	SELECT
    p.center || 'p' || p.id AS PERSONKEY,
	pea_mobile.txtvalue AS PhoneMobile,
    DECODE (p.STATUS, 0,'LEAD', 1,'ACTIVE', 2,'INACTIVE', 3,'TEMPORARYINACTIVE', 4,'TRANSFERED', 5,'DUPLICATE', 6,'PROSPECT', 7,'DELETED',8, 'ANONYMIZED', 9, 'CONTACT', 'UNKNOWN') AS Current_Status,

    DECODE (p.PERSONTYPE, 0,'PRIVATE', 1,'STUDENT', 2,'STAFF', 3,'FRIEND', 4,'CORPORATE', 5,'ONEMANCORPORATE', 6,'FAMILY', 7,'SENIOR', 8,'GUEST','UNKNOWN')                         AS PERSONTYPE, 
 TO_CHAR(longtodate(pcl.ENTRY_TIME), 'YYYY-MM-DD') AS Dato,
 	CASE
		WHEN p.CENTER IS NOT NULL
		THEN 'HOTCONTACT'
		ELSE NULL
	END 													AS TYPE
 

 



FROM
    persons p

JOIN
    PERSON_CHANGE_LOGS pcl
ON
    p.center= pcl.PERSON_CENTER
    AND p.id = pcl.PERSON_ID
    AND pcl.CHANGE_ATTRIBUTE = 'HOTCONTACTSTATUS'
    AND pcl.NEW_VALUE = 'YES'
	
	JOIN
    PERSON_EXT_ATTRS pea_mobile
ON
    pea_mobile.PERSONCENTER = p.center
AND pea_mobile.PERSONID = p.id
AND pea_mobile.NAME = '_eClub_PhoneSMS'


WHERE
    
    p.persontype != 2
    AND p.center IN (:Scope)
	AND longToDate(pcl.ENTRY_TIME) >= TRUNC(:FROM_date)
	AND longToDate(pcl.ENTRY_TIME) < TRUNC(:TOO_date)
	
	UNION ALL
	
	SELECT 
    p2.center || 'p' || p2.id AS PERSONKEY,
	 pea_mobile2.txtvalue AS PhoneMobile,
    DECODE (p2.STATUS, 0,'LEAD', 1,'ACTIVE', 2,'INACTIVE', 3,'TEMPORARYINACTIVE', 4,'TRANSFERED', 5,'DUPLICATE', 6,'PROSPECT', 7,'DELETED',8, 'ANONYMIZED', 9, 'CONTACT', 'UNKNOWN') AS Current_Status,
	DECODE (p2.PERSONTYPE, 0,'PRIVATE', 1,'STUDENT', 2,'STAFF', 3,'FRIEND', 4,'CORPORATE', 5,'ONEMANCORPORATE', 6,'FAMILY', 7,'SENIOR', 8,'GUEST','UNKNOWN') AS PERSONTYPE, 
	pea_creationdate2.TXTVALUE AS Dato,
	 	CASE
		WHEN p2.CENTER IS NOT NULL
		THEN 'NEWLEAD'
		ELSE NULL
	END 													AS TYPE
 
 
 From persons p2
 
 JOIN
    PERSON_EXT_ATTRS pea_creationdate2
ON
    pea_creationdate2.PERSONCENTER = p2.center
AND pea_creationdate2.PERSONID = p2.id
AND pea_creationdate2.NAME = 'CREATION_DATE'

JOIN
    PERSON_EXT_ATTRS pea_mobile2
ON
    pea_mobile2.PERSONCENTER = p2.center
AND pea_mobile2.PERSONID = p2.id
AND pea_mobile2.NAME = '_eClub_PhoneSMS'

WHERE

    p2.persontype != 2
    AND p2.center IN (:Scope)
	AND TO_DATE(pea_creationdate2.TXTVALUE, 'YYYY-MM-DD') BETWEEN TRUNC(:FROM_date) AND TRUNC(:TOO_date)
	AND p2.STATUS IN (0,
                   6,
                   9)
	
	
	
	
