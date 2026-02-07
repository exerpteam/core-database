SELECT
	cen.COUNTRY,
	cen.name 									AS Center,
	per.CENTER || 'p' || per.ID 						AS PersonId,
	DECODE (per.status, 0,'LEAD', 1,'ACTIVE', 2,'INACTIVE', 3,'TEMPORARY INACTIVE', 4,'TRANSFERED', 5,'DUPLICATE', 6, 'PROSPECT',7,'DELETED',9,'CONTACT', 'UNKNOWN')  AS CURRENT_PERSONSTATUS,
    DECODE (scl_pstatus.STATEID, 0,'LEAD', 1,'ACTIVE', 2,'INACTIVE', 3,'TEMPORARY INACTIVE', 4,'TRANSFERED', 5,'DUPLICATE', 6, 'PROSPECT',7,'DELETED',9,'CONTACT', 'UNKNOWN')  AS PERSONSTATUS,
	pea_creationdate.TXTVALUE						 	AS CreationDate,
	longToDate(scl_pstatus.ENTRY_START_TIME) AS PStatus_Entry_Date
	
FROM
    PERSONS per

LEFT JOIN CENTERS cen
ON
	per.CENTER = cen.ID


	
LEFT JOIN PERSON_EXT_ATTRS pea_creationdate
ON
    pea_creationdate.PERSONCENTER = per.center
	AND pea_creationdate.PERSONID = per.id
	AND pea_creationdate.NAME = 'CREATION_DATE'
	
	
LEFT JOIN STATE_CHANGE_LOG scl_pstatus
ON
    per.CENTER = scl_pstatus.CENTER
    AND per.ID = scl_pstatus.ID

  
Where per.center IN (:Scope)
	
--AND scl_pstatus.ENTRY_START_TIME >= datetolong(TO_CHAR(TRUNC(exerpsysdate() -1), 'YYYY-MM-DD HH24:MI')) -- yesterday at midnight
	
--AND scl_pstatus.ENTRY_START_TIME < datetolong(TO_CHAR(TRUNC(exerpsysdate() -1), 'YYYY-MM-DD HH24:MI')) + 86399*1000 -- yesterday at midnight +24 hours --in ms


 AND scl_pstatus.ENTRY_START_TIME >= :FromDate
 AND scl_pstatus.ENTRY_START_TIME < :ToDate + 3600*1000*24
