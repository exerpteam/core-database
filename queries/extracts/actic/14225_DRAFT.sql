-- The extract is extracted from Exerp on 2026-02-08
--  
/* Decoded state change log */
-- still missing some info...
SELECT
	scl.CENTER,
	scl.ID,
	scl.SUBID,
	DECODE (scl.ENTRY_TYPE, 1,'1:PERSONSTATUS', 2,'2:SUBSTATE', 3,'3:PERSONTYPE', 4,'4:COMPANY', 5,'5:UNKNOWN','UNKNOWN') AS Entry_Type,
	-- scl.STATEID,
	CASE
		WHEN scl.ENTRY_TYPE = 1
		THEN DECODE (scl.STATEID, 0,'LEAD', 1,'ACTIVE', 2,'INACTIVE', 3,'TEMPORARYINACTIVE', 4,'TRANSFERED', 5,'DUPLICATE', 6,'PROSPECT', 7,'DELETED','UNKNOWN')

		WHEN scl.ENTRY_TYPE = 2
		THEN DECODE (scl.STATEID, 2,'ACTIVE', 3,'ENDED', 4,'FROZEN', 7,'WINDOW', 8,'CREATED','UNKNOWN')

		WHEN scl.ENTRY_TYPE = 3
		THEN DECODE (scl.STATEID, 0,'PRIVATE', 1,'STUDENT', 2,'STAFF', 3,'FRIEND', 4,'CORPORATE', 5,'ONEMANCORPORATE', 6,'FAMILY', 7,'SENIOR', 8,'GUEST', 9,'CONTACT', 'UNKNOWN')

		WHEN scl.ENTRY_TYPE = 4
		THEN DECODE (scl.STATEID, 0,'0', 1,'1', 2,'2', 3,'3:BLOCKED??', 4,'4', 5,'5', 6,'6', 7,'7', 8,'8', 9,'9', 'UNKNOWN')

		ELSE TO_CHAR(scl.STATEID)
	END STATEID,
	scl.SUB_STATE,
	scl.ENTRY_START_TIME,
	scl.ENTRY_END_TIME,
	TO_CHAR(longToDate(scl.ENTRY_START_TIME), 'YYYY-MM-DD HH24:MI')		AS Entry_Start,
	TO_CHAR(longToDate(scl.ENTRY_END_TIME), 'YYYY-MM-DD HH24:MI')		AS Entry_End,
	scl.KEY,
	companyAgrRel.RELATIVECENTER,
	companyAgrRel.RELATIVEID,
	companyAgrRel.RELATIVESUBID
FROM state_change_log scl
LEFT JOIN RELATIVES companyAgrRel
ON
	scl.CENTER = companyAgrRel.CENTER
	AND scl.ID = companyAgrRel.ID
	AND scl.SUBID = companyAgrRel.SUBID
	AND companyAgrRel.RTYPE = 3
	AND scl.ENTRY_TYPE = 4
where scl.CENTER = :Center