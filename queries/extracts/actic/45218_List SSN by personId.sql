-- The extract is extracted from Exerp on 2026-02-08
--  
SELECT
    cen.NAME CLUB,
	per.center,
    per.center || 'p' || per.id personid,
    per.ssn,
    DECODE (per.PERSONTYPE, 0,'PRIVATE', 1,'STUDENT', 2,'STAFF', 3,'FRIEND', 4,'CORPORATE', 5,'ONEMANCORPORATE', 6,'FAMILY', 7,'SENIOR', 8,'GUEST','UNKNOWN') PERSONTYPE, 
    DECODE (per.STATUS, 0,'LEAD', 1,'ACTIVE', 2,'INACTIVE', 3,'TEMPORARYINACTIVE', 4,'TRANSFERED', 5,'DUPLICATE', 6,'PROSPECT', 7,'DELETED','UNKNOWN') PERSONSTATUS,
    per.FIRSTNAME,
    per.LASTNAME
FROM
    PERSONS per
JOIN centers cen
ON
    cen.ID = per.CENTER

WHERE
	 per.center || 'p' || per.id in (:personId)