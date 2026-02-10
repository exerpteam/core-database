-- The extract is extracted from Exerp on 2026-02-08
--  
WITH
    params AS
    (
        SELECT
            /*+ materialize */
            datetolongTZ(TO_CHAR(TRUNC(SYSDATE), 'YYYY-MM-dd HH24:MI'), 'Europe/Stockholm')                   AS StartDateLong,
            (datetolongTZ(TO_CHAR(TRUNC(SYSDATE), 'YYYY-MM-dd HH24:MI'), 'Europe/Stockholm')+ 86400 * 1000) AS EndDateLong
        FROM
            dual
    )

SELECT
    p.center AS CENTER,
	CAST ( c.External_ID AS VARCHAR(255)) As COST,
    p.center || 'p' || p.id AS PERSONKEY,
	 p.external_id,
	TO_CHAR(trunc(months_between(TRUNC(exerpsysdate()), p.birthdate)/12)) AS Age,
p.sex,
    DECODE (p.STATUS, 0,'LEAD', 1,'ACTIVE', 2,'INACTIVE', 3,'TEMPORARYINACTIVE', 4,'TRANSFERED', 5,'DUPLICATE', 6,'PROSPECT', 7,'DELETED',8, 'ANONYMIZED', 9, 'CONTACT', 'UNKNOWN') AS Current_Status,

    DECODE (p.PERSONTYPE, 0,'PRIVATE', 1,'STUDENT', 2,'STAFF', 3,'FRIEND', 4,'CORPORATE', 5,'ONEMANCORPORATE', 6,'FAMILY', 7,'SENIOR', 8,'GUEST','UNKNOWN')                         AS PERSONTYPE, 
pcl.CHANGE_ATTRIBUTE                                                                                                                                                   AS HotContactValue,
 TO_CHAR(longtodate(pcl.ENTRY_TIME), 'YYYY-MM-DD') AS HOTCONTACT_DATE


FROM
    persons p
CROSS JOIN
    params
JOIN
    PERSON_CHANGE_LOGS pcl
ON
    p.center= pcl.PERSON_CENTER
    AND p.id = pcl.PERSON_ID
    AND pcl.CHANGE_ATTRIBUTE = 'HOTCONTACTSTATUS'
    AND pcl.NEW_VALUE = 'YES'


JOIN CENTERS c
ON
p.center = c.id

WHERE
    
    p.persontype != 2
    AND p.center IN (:Scope)
	AND pcl.ENTRY_TIME >= params.StartDateLong
    AND pcl.ENTRY_TIME <= params.EndDateLong
    