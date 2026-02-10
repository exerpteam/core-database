-- The extract is extracted from Exerp on 2026-02-08
--  

SELECT
    cp.EXTERNAL_ID,
    e.IDENTITY     AS PIN,
        cp.SEX AS GENDER,
	DECODE ( CP.PERSONTYPE, 0,'PRIVATE', 1,'STUDENT', 2,'STAFF', 3,'FRIEND', 4,'CORPORATE', 5,'ONEMANCORPORATE', 6,'FAMILY', 7,'SENIOR', 8,'GUEST','UNKNOWN') AS PERSONTYPE,
    att.center     AS CENTER_ID,
    c.SHORTNAME    AS Center_Name,
    br.EXTERNAL_ID AS Door_ID,
    br.NAME        AS Door_Name,
    TO_CHAR(TRUNC(longToDateTZ(att.START_TIME,'Europe/London'),'HH'),'dd-MM-YYYY') AS "DATE",
    TO_CHAR(longtodatetz(att.START_TIME,'Europe/London'),'HH24:MI:SS') AS "Timestamp"
FROM
    PUREGYM.ATTENDS att
JOIN
    PUREGYM.PERSONS p
ON
    p.center = att.PERSON_CENTER
    AND p.id = att.PERSON_ID
JOIN
    PUREGYM.PERSONS cp
ON
    cp.center = p.CURRENT_PERSON_CENTER
    AND cp.id = p.CURRENT_PERSON_ID
JOIN
    PUREGYM.BOOKING_RESOURCES br
ON
    br.center = att.BOOKING_RESOURCE_CENTER
    AND br.id = att.BOOKING_RESOURCE_ID
LEFT JOIN
    PUREGYM.ENTITYIDENTIFIERS e
ON
    e.IDMETHOD = 5
    AND e.ENTITYSTATUS = 1
    AND e.REF_CENTER = p.CENTER
    AND e.REF_ID = p.ID
    AND e.REF_TYPE = 1
JOIN
    PUREGYM.CENTERS c
ON
    c.ID = att.CENTER