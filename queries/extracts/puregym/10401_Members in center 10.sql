-- The extract is extracted from Exerp on 2026-02-08
--  
SELECT
    'Birmingham City Centre'                                                                                                                                 AS PERSON_CENTER,
    att.PERSON_CENTER||'p'||att.PERSON_ID                                                                                                                    AS PERSON_ID,
    DECODE ( p.PERSONTYPE, 0,'PRIVATE', 1,'STUDENT', 2,'STAFF', 3,'FRIEND', 4,'CORPORATE', 5,'ONEMANCORPORATE', 6,'FAMILY', 7,'SENIOR', 8,'GUEST','UNKNOWN') AS PERSONTYPE,
    p.FULLNAME,
    e.IDENTITY                                                         AS PIN,
    TO_CHAR(longtodatetz(att.START_TIME,'Europe/London'),'yyyy-MM-dd')    Attend_Date,
    TO_CHAR(longtodatetz(att.START_TIME,'Europe/London'),'HH24:MI')       Attend_Time
FROM
    PUREGYM.ATTENDS att
LEFT JOIN
    PUREGYM.ENTITYIDENTIFIERS e
ON
    e.IDMETHOD = 5
    AND e.ENTITYSTATUS = 1
    AND e.REF_CENTER = att.PERSON_CENTER
    AND e.REF_ID = att.PERSON_ID
    AND e.REF_TYPE = 1
JOIN
    persons p
ON
    p.center = att.PERSON_CENTER
    AND p.id = att.PERSON_ID
WHERE
    att.CENTER = 10
    AND att.BOOKING_RESOURCE_ID IN(5,401)--checkins
    AND att.START_TIME > dateToLong(TO_CHAR(SYSDATE, 'YYYY-MM-dd HH24:MI')) - 1000*60*60*8
    AND NOT EXISTS
    (
        SELECT
            1
        FROM
            PUREGYM.ATTENDS att2
        WHERE
            att2.CENTER = 10
            AND att2.BOOKING_RESOURCE_ID IN(6,601) --checkouts
            AND att2.PERSON_CENTER = att.PERSON_CENTER
            AND att2.PERSON_ID = att.PERSON_ID
            AND att.START_TIME<att2.START_TIME)