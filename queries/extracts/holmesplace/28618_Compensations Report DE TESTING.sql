select 
	PA.PERSONCENTER,
	PA.PERSONID,
	PA.NAME AS "EXT ATT",
	PA.TXTVALUE,
	TO_CHAR(longtodateC(PA.LAST_EDIT_TIME, p.CENTER),'YYYY-MM-DD HH24:MI:SS') AS "EXT ATT LAST UPDATE",
	p.FULLNAME AS PERSON_NAME,
	DECODE (p.STATUS, 0,'LEAD', 1,'ACTIVE', 2,'INACTIVE', 3,'TEMPORARYINACTIVE', 4,'TRANSFERED', 5,'DUPLICATE', 6,'PROSPECT', 7,'DELETED',8, 'ANONYMIZED', 9, 'CONTACT', 'UNKNOWN') AS PERSON_STATUS,
	DECODE ( p.PERSONTYPE, 0,'PRIVATE', 1,'STUDENT', 2,'STAFF', 3,'FRIEND', 4,'CORPORATE', 5,'ONEMANCORPORATE', 6,'FAMILY', 7,'SENIOR', 8,'GUEST','UNKNOWN')                        AS PERSONTYPE,
	compensation.txtvalue AS CompChosen APR MAY

	pem.txtvalue AS email
	
from PERSONS P 
join PERSON_EXT_ATTRS PA 
	on PA.personcenter = P.center 
	and PA.personid=P.id
left join PERSON_EXT_ATTRS pem on pem.personcenter = p.center and pem.personid = p.id and pem.name = '_eClub_Email'

LEFT JOIN
    PERSON_EXT_ATTRS compensation
ON
    owner.center = compensation.PERSONCENTER
    AND owner.id = compensation.PERSONID
    AND compensation.name = 'CompChosen APR MAY'

WHERE 
	P.center IN (:center) 
    AND PA.NAME IN (:Person_Ext_Attributes)
 	AND P.STATUS IN ( :PersonStatus )
	AND PA.TXTVALUE IS NOT NULL